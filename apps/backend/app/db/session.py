from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
# from app.core.config import setting

engine = create_engine("", pool_pre_ping=True)

session_local = sessionmaker(autocommit=False, autoflush=False, bind=engine)
