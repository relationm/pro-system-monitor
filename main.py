import os
from datetime import datetime
from fastapi import FastAPI, Header, HTTPException, Depends, status
from pydantic import BaseModel
from sqlalchemy import create_engine, Column, Integer, Float, String, TIMESTAMP, ForeignKey
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, Session

# Database URL points to 'db' service name instead of 'localhost'
# We use environment variables for flexibility
DB_USER = os.getenv("DB_USER", "root")
DB_PASS = os.getenv("DB_PASSWORD", "password")
DB_NAME = os.getenv("DB_NAME", "system_monitor")
DB_HOST = os.getenv("DB_HOST", "db") # 'db' is the docker service name

DATABASE_URL = f"mysql+pymysql://{DB_USER}:{DB_PASS}@{DB_HOST}/{DB_NAME}"

engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

# Models
class Server(Base):
    __tablename__ = "servers"
    id = Column(Integer, primary_key=True)
    hostname = Column(String(255))
    api_key = Column(String(64), unique=True)

class Metric(Base):
    __tablename__ = "metrics"
    id = Column(Integer, primary_key=True)
    server_id = Column(Integer, ForeignKey("servers.id"))
    cpu_usage_percent = Column(Float)
    load_average = Column(Float)
    memory_free_mb = Column(Integer)
    disk_free_gb = Column(Float)
    iowait_percent = Column(Float)
    recorded_at = Column(TIMESTAMP, default=datetime.utcnow)

class MetricCreate(BaseModel):
    cpu_usage_percent: float
    load_average: float
    memory_free_mb: int
    disk_free_gb: float
    iowait_percent: float

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

app = FastAPI(title="Pro System Monitor API")

@app.post("/api/v1/metrics")
async def collect_metrics(metrics: MetricCreate, x_api_key: str = Header(None), db: Session = Depends(get_db)):
    server = db.query(Server).filter(Server.api_key == x_api_key).first()
    if not server:
        raise HTTPException(status_code=401, detail="Invalid API Key")

    new_entry = Metric(server_id=server.id, **metrics.dict())
    db.add(new_entry)
    db.commit()
    return {"status": "recorded"}

@app.get("/health")
def health():
    return {"status": "ok"}