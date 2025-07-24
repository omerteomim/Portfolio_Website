# Create ZIP file for Lambda function
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file  = "../lambda_function.py"
  output_path = var.lambda_zip_path
}