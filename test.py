import joblib
import librosa
import numpy as np
from playsound import playsound


# Function to extract and preprocess audio features
def extract_and_preprocess_audio_features(audio_file):
    # Initialize lists to store extracted features
    audio_features = []

    # Load the audio file
    y, sr = librosa.load(audio_file, duration=3)  # Limit duration to 3 seconds

    # Extract MFCC features
    mfcc = librosa.feature.mfcc(y=y, sr=sr, n_mfcc=13)
    mean_mfcc = np.mean(mfcc, axis=1)

    # Extract Chroma features
    chroma = librosa.feature.chroma_stft(y=y, sr=sr)
    mean_chroma = np.mean(chroma, axis=1)

    # Calculate Zero Crossing Rate
    zcr = np.mean(librosa.feature.zero_crossing_rate(y))

    # Calculate Spectral Roll-off
    spectral_rolloff = np.mean(librosa.feature.spectral_rolloff(y=y, sr=sr))

    # Calculate Spectral Contrast
    spectral_contrast = np.mean(librosa.feature.spectral_contrast(y=y, sr=sr))

    # Combine all features into one feature vector for this audio sample
    feature_vector = np.concatenate(
        [
            mean_mfcc,
            mean_chroma,
            [zcr],
            [spectral_rolloff],
            [spectral_contrast],
        ]
    )

    return feature_vector


# Specify the path to the input audio sample you want to process
# input_audio_sample = "C:/Users/91930/OneDrive/Documents/DSP/audio/26_female.wav"
input_audio_sample = "audio.wav"
playsound(input_audio_sample)

# Extract and preprocess features from the input audio sample
new_data = extract_and_preprocess_audio_features(input_audio_sample)

# Load the trained XGBoost model
model_filename = "gender_prediction_model_xgb.pkl"
loaded_model = joblib.load(model_filename)

# Make predictions for the input data
# The input data should be a NumPy array with the same number of features as the training data
# Ensure that 'new_data' has the same number of features as the data used for model training
prediction = loaded_model.predict([new_data])

# Extract the integer value from the list
predicted_gender = int(prediction[0])

print(predicted_gender)
# The 'predicted_gender' variable will contain the predicted gender label (0 for female, 1 for male)
