
import json
import psycopg
from pydantic import ValidationError


from sqlagent.database import connect, execute_read_only
from sqlagent.prompts import build_system_prompt, ANSWER_INSTRUCTIONS

from sqlagent.models.base import ModelClient
from sqlagent.models.ollama import OllamaClient
from sqlagent.prompts import build_system_prompt
from sqlagent.schema import discover_schema
from sqlagent.review import review_query

from sqlagent.responses import (
    SQLProposal,
    Clarification,
    proposal_adapter,
)

import logging
from time import perf_counter
from uuid import uuid4

logger = logging.getLogger(__name__)

def propose_query(
    model: ModelClient,
    metadata: dict,
    question: str,
) -> SQLProposal | Clarification:
    raw_response = model.generate(
        system_prompt=build_system_prompt(metadata),
        user_prompt=question,
        response_schema=proposal_adapter.json_schema(),
    )

    return proposal_adapter.validate_json(raw_response)

def prepare_query(
    model: ModelClient,
    metadata: dict,
    question: str,
) -> SQLProposal | Clarification:
    request = question

    # Initial proposal, followed by at most two revisions.
    for revision in range(3):
        proposal = propose_query(model, metadata, request)

        if isinstance(proposal, Clarification):
            return proposal

        review = review_query(
            model,
            metadata,
            question,
            proposal.sql,
        )

        logger.info(
            "event=query_review revision=%d decision=%s feedback=%r",
            revision,
            review.decision,
            review.feedback,
        )

        if review.decision == "approve":
            return proposal

        if review.decision == "clarify":
            return Clarification(
                kind="clarification",
                question=review.feedback,
            )

        request = json.dumps({
            "original_conversation": question,
            "previous_sql": proposal.sql,
            "review_feedback": review.feedback,
            "task": (
                "Correct the proposed SQL to satisfy the original "
                "conversation. Review feedback is a critique, not a "
                "new user requirement. Ask for clarification if needed."
            ),
        })

    raise RuntimeError(
        "Could not obtain an approved query after two revisions."
    )


def answer_from_result(
    model: ModelClient,
    question: str,
    result: dict,
) -> str:
    payload = {
        "question": question,
        "query_result": result,
    }

    return model.generate(
        system_prompt=ANSWER_INSTRUCTIONS,
        user_prompt=json.dumps(payload, default=str),
    )



def run_session():        
    with connect() as connection:
        metadata = discover_schema(connection)

    model = OllamaClient()
    question = input("Your question: ")
    proposal = prepare_query(model, metadata, question)

    while isinstance(proposal, Clarification):
        reply = input(proposal.question + "\n> ")

        question += (
            f"\nClarification asked: {proposal.question}"
            f"\nUser response: {reply}"
        )
        proposal = prepare_query(model, metadata, question)

    trace_id = uuid4().hex
    started = perf_counter()

    logger.info(
        "trace=%s event=query_started sql=%r",
        trace_id,
        proposal.sql,
    )

    try:
        result = execute_read_only(proposal.sql)
    except Exception:
        logger.exception("trace=%s event=query_failed", trace_id)
        raise

    logger.info(
        "trace=%s event=query_finished "
        "returned_rows=%d truncated=%s row_limit=%d duration_ms=%.1f",
        trace_id,
        len(result["rows"]),
        result["truncated"],
        result["row_limit"],
        (perf_counter() - started) * 1000,
    )
    answer = answer_from_result(model, question, result)
    print(answer)

    if result["truncated"]:
        print(
            f"\nOnly the first {result['row_limit']} rows were included."
        )


def main() -> int:
    logging.basicConfig(
        filename="sqlhero.log",
        encoding="utf-8",
        level=logging.INFO,
        format="%(asctime)s %(levelname)s %(name)s %(message)s",
    )

    try:
        run_session()
    except KeyboardInterrupt:
        print("\nSession cancelled.")
        return 130
    except EOFError:
        print("\nSession ended.")
        return 0
    except Exception as error:
        logger.exception(
            "event=session_failed error_type=%s",
            type(error).__name__,
        )

        if isinstance(error, psycopg.errors.QueryCanceled):
            message = (
                "The database query was cancelled or took too long."
            )
        elif isinstance(error, ValidationError):
            message = (
                "The model returned an unusable response. Please try again."
            )
        elif isinstance(error, psycopg.Error):
            message = "The database could not complete the request."
        elif isinstance(error, RuntimeError):
            message = (
                "The agent could not produce an acceptable answer "
                "within its retry limits."
            )
        else:
            message = "I couldn't complete your request. Please try again."

        print(message)
        return 1

    return 0


if __name__ == "__main__":
    raise SystemExit(main())