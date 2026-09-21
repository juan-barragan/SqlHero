import json

from sqlagent.models.base import ModelClient
from sqlagent.prompts import REVIEW_INSTRUCTIONS
from sqlagent.responses import QueryReview


def review_query(
    model: ModelClient,
    metadata: dict,
    question: str,
    sql: str,
) -> QueryReview:
    payload = {
        "conversation": question,
        "metadata": metadata,
        "proposed_sql": sql,
    }

    raw_response = model.generate(
        system_prompt=REVIEW_INSTRUCTIONS,
        user_prompt=json.dumps(payload),
        response_schema=QueryReview.model_json_schema(),
    )

    return QueryReview.model_validate_json(raw_response)