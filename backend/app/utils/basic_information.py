from enum import Enum
from dataclasses import dataclass
    
class Role(Enum):
    ADMIN = "Admin"
    TEACHER = "Teacher"
    STUDENT = "Student"