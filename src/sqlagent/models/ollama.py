from ollama import Client 

from sqlagent.models.base import ModelClient

import logging

logger = logging.getLogger(__name__)

class OllamaClient(ModelClient):
    def __init__(
            self,
            model: str = "gpt-oss:20b",
            host: str = "http://localhost:11434"
    ):
        self.model = model
        self.client = Client(host = host, timeout=120)

    def generate(
        self,
        system_prompt: str,
        user_prompt: str,
        *,
        response_schema: dict | None = None,
    ) -> str:
        for attempt in range(2):
            response = self.client.chat(
                model=self.model,
                messages=[
                    {"role": "system", "content": system_prompt},
                    {"role": "user", "content": user_prompt},
                ],
                stream=False,
                options={"num_ctx": 16384},
                format=response_schema,
            )

            content = response.message.content

            if content and content.strip():
                return content

            logger.warning(
                "event=empty_model_response model=%s attempt=%d "
                "done_reason=%s prompt_tokens=%s generated_tokens=%s",
                self.model,
                attempt + 1,
                response.done_reason,
                response.prompt_eval_count,
                response.eval_count,
            )

        raise RuntimeError(
            "Ollama returned an empty answer on both attempts."
        )

if __name__ == "__main__":
    model = OllamaClient()
    answer = model.generate(
        system_prompt="Explain PostgreSQL concepts briefly.",
        user_prompt="What is a foreign key?",
    )
    print(answer)