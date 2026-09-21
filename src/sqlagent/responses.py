from typing import Literal

from pydantic import BaseModel, ConfigDict, Field, TypeAdapter


class SQLProposal(BaseModel):
    model_config = ConfigDict(
        extra="forbid",
        str_strip_whitespace=True,
    )

    kind: Literal["sql"]
    sql: str = Field(min_length=1)

class Clarification(BaseModel):
    model_config = ConfigDict(
        extra="forbid",
        str_strip_whitespace=True
    )

    kind: Literal["clarification"]
    question: str = Field(min_length=1)


class QueryReview(BaseModel):
    model_config = ConfigDict(
        extra="forbid",
        str_strip_whitespace=True,
    )

    decision: Literal["approve", "revise", "clarify"]
    feedback: str = Field(min_length=1)

proposal_adapter = TypeAdapter(SQLProposal | Clarification)