import datetime
import os
import re
from urllib.parse import unquote_plus

import boto3

transcribe = boto3.client("transcribe")


def handler(event, context):
    # Get event data
    input_bucket = event["Records"][0]["s3"]["bucket"]["name"]
    input_key = unquote_plus(
        event["Records"][0]["s3"]["object"]["key"], encoding="utf-8"
    )
    wav_name = os.path.splitext(os.path.basename(input_key))[0]
    print(f"Received event for {input_key} from bucket {input_bucket}.")

    # Define the job name and audio file URI
    input_file_uri = f"s3://{input_bucket}/{input_key}"
    output_bucket = input_bucket
    output_key = f"transcriptions/{wav_name}.json"
    output_file_uri = f"s3://{output_bucket}/{output_key}"
    timestamp = datetime.datetime.now().strftime("%Y%m%d-%H%M%S")
    transcription_job_name = f"transcription-{wav_name}-{timestamp}"
    transcription_job_name = re.sub(
        r"[^0-9a-zA-Z._-]", "_", transcription_job_name
    )  # Transcribe job name must be alphanumeric
    print(f"Output file URI: {output_file_uri}")

    # Start transcription job
    try:
        transcribe.start_transcription_job(
            TranscriptionJobName=transcription_job_name,
            Media={"MediaFileUri": input_file_uri},
            MediaFormat="wav",
            LanguageCode="ja-JP",
            OutputBucketName=output_bucket,
            OutputKey=output_key,
        )
        print(f"Transcription job {transcription_job_name} started.")

        return {
            "statusCode": 200,
            "body": f"Transcription job {transcription_job_name} started for {input_key}.",
        }
    except Exception as e:
        print(
            f"Error starting transcription job for object {input_key} from bucket {input_bucket}."
            "Make sure they exist and your bucket is in the same region as this function."
        )
        raise e
