
## Windows Install

```
# install uv
powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"

# create virtual environment
uv venv

# activate virtual environment
.venv\Scripts\activate.bat

# install dependencies
make sync
```

## Linux install

Follow the instructions here: https://docs.astral.sh/uv/getting-started/installation/

```
# create virtual environment
uv venv

# activate virtual environment
.venv/bin/activate

# install dependencies
make sync
```
