from sklearn.preprocessing import LabelEncoder
from sklearn.model_selection import train_test_split
import pandas as pd
import xgboost as xgb
from sklearn.metrics import accuracy_score, classification_report
import joblib

# Replace 'your_file.csv' with the actual path to your CSV file
csv_file_path = "C:/Users/91930/OneDrive/Documents/DSP/audio.csv"

# Load the data from the CSV file into a DataFrame
df = pd.read_csv(csv_file_path)

# Encode the gender labels
label_encoder = LabelEncoder()
df["Gender"] = label_encoder.fit_transform(df["Gender"])

# Split the data into training, validation, and test sets
train_data, test_data = train_test_split(df, test_size=0.3, random_state=42)
validation_data, test_data = train_test_split(test_data, test_size=0.5, random_state=42)

# Separate the features and labels
X_train = train_data.drop(["File Name", "Gender"], axis=1)
y_train = train_data["Gender"]
X_val = validation_data.drop(["File Name", "Gender"], axis=1)
y_val = validation_data["Gender"]
X_test = test_data.drop(["File Name", "Gender"], axis=1)
y_test = test_data["Gender"]

# Step 3: Model Building and Training

# Create an XGBoost classifier (you can adjust hyperparameters if needed)
model = xgb.XGBClassifier(objective="binary:logistic", random_state=42)

# Train the model on the training data
model.fit(X_train, y_train)

# Step 4: Model Evaluation

# Validate the model on the validation set
y_val_pred = model.predict(X_val)
val_accuracy = accuracy_score(y_val, y_val_pred)

print(f"Validation accuracy: {val_accuracy:.2f}")

# Test the model on the test set
y_test_pred = model.predict(X_test)
test_accuracy = accuracy_score(y_test, y_test_pred)

print(f"Test accuracy: {test_accuracy:.2f}")

# View a detailed classification report
print(classification_report(y_test, y_test_pred))

# Step 5: Model Deployment

# Save the trained model to a file
model_filename = "gender_prediction_model_xgb.pkl"
joblib.dump(model, model_filename)

print(f"XGBoost model saved as '{model_filename}'")

# Get feature importances from the trained XGBoost model
feature_importances = model.feature_importances_

# Create a DataFrame to display feature names and their importances
importance_df = pd.DataFrame(
    {"Feature": X_train.columns, "Importance": feature_importances}
)

# Sort the features by importance in descending order
importance_df = importance_df.sort_values(by="Importance", ascending=False)

# Display the top N most important features (you can adjust N)
top_n_features = 10
print(importance_df.head(top_n_features))
