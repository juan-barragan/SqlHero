from ollama import Client 

from sqlagent.models.base import ModelClient

class OllamaClient(ModelClient):
    def __init__(
            self,
            model: str = "gpt-oss:20b",
            host: str = "http://localhost:11434"
    ):
        self.model = model
        self.client = Client(host = host, timeout=120)

    def generate(self, system_prompt: str, user_prompt: str) -> str:
        response = self.client.chat(
            model = self.model,
            messages = [
                {"role" : "system", "content": system_prompt},
                {"role": "user", "content": user_prompt}
            ],
            stream = False
        )
        return response.message.content or ""

if __name__ == "__main__":
    model = OllamaClient()
    answer = model.generate(
        system_prompt="Explain PostgreSQL concepts briefly.",
        user_prompt="What is a foreign key?",
    )
    print(answer)