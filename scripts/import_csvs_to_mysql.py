import os
import pandas as pd
from sqlalchemy import create_engine

try:
    engine = create_engine("mysql+pymysql://root:mypass@localhost/ecommerce")
    folder = r"C:\Users\kimme\Desktop\Projects\e-commerce-analysis\data\raw_data"

    for file in os.listdir(folder):
        if file.endswith(".csv"):
            table = file.replace(".csv", "")
            print(f"Importing {table}...")
            df = pd.read_csv(os.path.join(folder, file))
            df.to_sql(table, con=engine, if_exists='replace', index=False, chunksize=10000)
            print(f"{table} imported successfully.")

    print("All CSV files imported successfully.")

except Exception as e:
    print("Error occurred:", e)
