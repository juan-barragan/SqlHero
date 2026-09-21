sqlagent/
├── TODO.md
├── README.md
├── pyproject.toml          # Dependencies and project configuration
├── src/
│   └── sqlagent/
│       ├── __init__.py
│       ├── app.py         # Web backend: receives questions, returns answers
│       ├── database.py    # PostgreSQL connections and SQL execution
│       ├── schema.py      # Discovers tables, columns, keys, relationships
│       ├── agent.py       # Coordinates model calls and tool execution
│       ├── tools.py       # Defines the operations available to the agent
│       ├── execution.py   # Controlled execution of generated Python
│       ├── models/
│       │   ├── __init__.py
│       │   ├── base.py    # Shared interface for model providers
│       │   └── ollama.py  # First provider; OpenAI/Claude come later
│       └── static/
│           └── index.html # Question input and answer display
└── tests/