import h5py
import sys

model_path = 'lstm_model_ziad.h5' # Make sure this path is correct

try:
    with h5py.File(model_path, 'r') as f:
        print("HDF5 file attributes:")
        for key, value in f.attrs.items():
            print(f"{key}: {value}")

        if 'keras_version' in f.attrs:
            print(f"\nFound Keras version attribute: {f.attrs['keras_version']}")
        else:
            print("\n'keras_version' attribute not found in file metadata.")

except FileNotFoundError:
    print(f"Error: Model file not found at {model_path}")
except Exception as e:
    print(f"An error occurred: {e}")