from sqlagent.database import connect
from sqlagent.models.base import ModelClient
from sqlagent.models.ollama import OllamaClient
from sqlagent.prompts import build_system_prompt
from sqlagent.schema import discover_schema


def propose_query(
    model: ModelClient,
    metadata: dict,
    question: str,
) -> str:
    return model.generate(
        system_prompt=build_system_prompt(metadata),
        user_prompt=question,
    )


if __name__ == "__main__":
    with connect() as connection:
        metadata = discover_schema(connection)

    model = OllamaClient()
    question = input("Your question: ")

    proposal = propose_query(model, metadata, question)
    print(proposal)