import pandas as pd
import random
from faker import Faker
from datetime import datetime, timedelta

fake = Faker()
random.seed(42)

policies = []
for i in range(10000):
    policies.append({
        "policy_id": f"POL-{i:06d}",
        "customer_id": f"CUST-{random.randint(1000, 9999)}",
        "product_type": random.choice(["Term Life", "Whole Life", "Annuity", "Universal Life"]),
        "state": fake.state_abbr(),
        "premium_amount": round(random.uniform(100, 5000), 2),
        "coverage_amount": random.choice([100000, 250000, 500000, 1000000]),
        "policy_start_date": fake.date_between(start_date="-5y", end_date="today"),
        "policy_status": random.choice(["Active", "Lapsed", "Cancelled", "Pending"]),
        "agent_id": f"AGT-{random.randint(100, 999)}",
        "created_at": datetime.now().isoformat()
    })

df = pd.DataFrame(policies)
df.to_csv("data/mock_policies.csv", index=False)
print(f"Generated {len(df)} rows")