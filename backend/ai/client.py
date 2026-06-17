import os
from openai import AsyncOpenAI


def get_client() -> AsyncOpenAI:
    return AsyncOpenAI(api_key=os.environ["OPENAI_API_KEY"])
