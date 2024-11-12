from sqlalchemy import Column, String, DateTime, func
from sqlalchemy.dialects.postgresql import UUID
import uuid
from app.db.base import Base

class User(Base):
    __tablename__ = "users"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    email = Column(String, unique=True, nullable=False, index=True)
    password = Column(String, nullable=False)
    first_name = Column(String, nullable=False)
    last_name = Column(String, nullable=False)
    created_at = Column(DateTime, server_default=func.now())
    last_updated_at = Column(DateTime, server_default=func.now())
    disabled_at = Column(DateTime, server_default=func.now())
    api_key = Column(UUID(as_uuid=True), default=uuid.uuid4)
