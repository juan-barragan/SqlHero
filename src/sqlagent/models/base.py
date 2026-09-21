from abc import ABC, abstractmethod


class ModelClient(ABC):
    @abstractmethod
    def generate(
        self,
        system_prompt: str,
        user_prompt: str,
        *,
        response_schema: dict | None = None,
    ) -> str:
        pass
