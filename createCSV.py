import os
import pandas as pd
import librosa
import numpy as np

# Directory where your audio samples are stored
data_dir = "C:/Users/91930/OneDrive/Documents/DSP/audio"

# Initialize lists to store information
file_names = []
gender_labels = []
mfcc_features = []
chroma_features = []
zero_crossing_rates = []
spectral_rolloffs = []
spectral_contrasts = []

# Iterate through the files in the directory
for filename in os.listdir(data_dir):
    if filename.endswith(".wav"):
        # Extract gender label from the file name
        gender = filename.split("_")[1].split(".")[0]

        # Load the audio file and extract various features
        file_path = os.path.join(data_dir, filename)
        y, sr = librosa.load(
            file_path, duration=3
        )  # Load the audio and limit duration to 3 seconds

        # MFCC features
        mfcc = librosa.feature.mfcc(y=y, sr=sr, n_mfcc=13)
        mfcc_mean = np.mean(mfcc, axis=1)

        # Chroma features
        chroma = librosa.feature.chroma_stft(y=y, sr=sr)
        chroma_mean = np.mean(chroma, axis=1)

        # Zero Crossing Rate
        zero_crossing_rate = np.mean(librosa.feature.zero_crossing_rate(y))

        # Spectral Roll-off
        spectral_rolloff = np.mean(librosa.feature.spectral_rolloff(y=y, sr=sr))

        # Spectral Contrast
        spectral_contrast = np.mean(librosa.feature.spectral_contrast(y=y, sr=sr))

        # Append the information to the lists
        file_names.append(filename)
        gender_labels.append(gender)
        mfcc_features.append(mfcc_mean)
        chroma_features.append(chroma_mean)
        zero_crossing_rates.append(zero_crossing_rate)
        spectral_rolloffs.append(spectral_rolloff)
        spectral_contrasts.append(spectral_contrast)

# Create a DataFrame to store the information
data = {"File Name": file_names, "Gender": gender_labels}
df = pd.DataFrame(data)

# Add audio features to the DataFrame
mfcc_columns = [f"MFCC_{i}" for i in range(len(mfcc_mean))]
df[mfcc_columns] = pd.DataFrame(mfcc_features)

chroma_columns = [f"Chroma_{i}" for i in range(len(chroma_mean))]
df[chroma_columns] = pd.DataFrame(chroma_features)

df["Zero Crossing Rate"] = zero_crossing_rates
df["Spectral Roll-off"] = spectral_rolloffs
df["Spectral Contrast"] = spectral_contrasts

# Define the path for the CSV file
csv_file = "C:/Users/91930/OneDrive/Documents/DSP/audio.csv"

# Save the DataFrame to a CSV file
df.to_csv(csv_file, index=False)

print(
    f"CSV file '{csv_file}' has been created with audio sample information and additional audio features."
)
