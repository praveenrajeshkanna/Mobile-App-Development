from fastapi import FastAPI, Request
from transformers import AutoTokenizer, AutoModelForSequenceClassification
import torch
from googletrans import Translator
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

# Initialize FastAPI app
app = FastAPI()



app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Or specify domains
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# Load the tokenizer and model
tokenizer = AutoTokenizer.from_pretrained("unitary/toxic-bert")
model = AutoModelForSequenceClassification.from_pretrained("unitary/toxic-bert")

# Move model to GPU if available
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
model.to(device)

# Google Translator
translator = Translator()

# Preprocess comments
def preprocess_comment(comment):
    encoding = tokenizer.encode_plus(
        comment,
        max_length=128,
        add_special_tokens=True,
        return_token_type_ids=False,
        padding='max_length',
        truncation=True,
        return_attention_mask=True,
        return_tensors='pt',
    )
    return encoding

# Detect toxic comment
def detect_toxic_comment(comment):
    inputs = preprocess_comment(comment)
    inputs = {key: val.to(device) for key, val in inputs.items()}

    with torch.no_grad():
        outputs = model(**inputs)
        logits = outputs.logits
        predictions = torch.sigmoid(logits)
        toxic_probabilities = predictions.squeeze().tolist()

    toxic_threshold = 0.5
    is_toxic = any(prob > toxic_threshold for prob in toxic_probabilities)
    return is_toxic


class Input(BaseModel):
    comment : str

# Define API endpoint
@app.post("/detect/")
async def detect_toxic(input: Input ):

    input = input.dict  ()
    comment = input["comment"]
    # Translate comment if necessary
    translated_comment = translator.translate(comment, dest="en").text.lower()

    # Check if the comment is toxic
    is_toxic = detect_toxic_comment(translated_comment)

    return {"is_toxic": is_toxic}