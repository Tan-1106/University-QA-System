from app.services import auth_service


# ELIT Login
async def elit_login(code: str) -> dict:
    response = await auth_service.elit_login(code)
    return response


# Refresh tokens
async def refresh_tokens(refresh_token: str) -> dict:
    new_tokens = await auth_service.refresh_tokens(refresh_token)
    return new_tokens

# Register user
async def register_user(register_data: dict) -> dict:
    user = await auth_service.register_user(register_data)
    return user


# Login user
async def login_user(login_data: dict) -> dict:
    email = login_data.get("email")
    password = login_data.get("password")
    tokens = await auth_service.login_user(email, password)
    return tokens