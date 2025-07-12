# 🌐 Portfolio Website

This repository contains the source code and content for my personal portfolio website, hosted via **GitHub Pages**.

**Live Site:** [omerteomim.github.io/Portfolio\_Website](https://omerteomim.github.io/Portfolio_Website)

-----

## 📄 About the Website

The portfolio showcases:

  * 🧑‍💻 **About Me**
  * 🛠️ **Skills and Technologies**
  * 📂 **Projects with GitHub links**
  * 📞 **Contact Information**

It's a fully responsive static website designed with clean HTML and CSS, and deployed using GitHub Pages.

-----

## 👨🏻‍💻 Contact Form Submission Backend

The contact form on this website is powered by a robust, serverless backend. This entire infrastructure is deployed using **Terraform** and leverages key **AWS services** to efficiently process user submissions.

### Architecture

The backend implements a clear and reliable flow for handling contact form data:

1.  **Frontend Request:** When a user submits the contact form, the JavaScript frontend sends an **HTTP POST request** to a dedicated **AWS API Gateway** endpoint.
2.  **API Gateway as Entry Point:** The API Gateway receives the form data and acts as the secure entry point. It's configured to directly invoke an AWS Lambda function.
3.  **AWS Lambda Function (Processing Logic):** This Lambda function executes upon invocation. Its primary responsibility is to take the incoming form data and publish it as a message to an **AWS SNS Topic**.
4.  **AWS SNS Topic (Messaging Hub):** The SNS Topic serves as a publish/subscribe messaging service. It receives the form data from the Lambda function, allowing for flexible integration with other services (e.g., sending notifications, storing data, or triggering further processing) without tightly coupling components.


```
[Frontend (JavaScript)] --(HTTP POST Request)--> [AWS API Gateway] --> [AWS Lambda Function] --> [AWS SNS Topic]
```

### Deployment (via Terraform)

The entire serverless backend infrastructure is defined and managed using [Terraform](https://www.terraform.io/). This ensures an infrastructure-as-code approach, enabling consistent and repeatable deployments.

The Terraform configuration includes:

  * **API Gateway resources:** For handling incoming HTTP requests.
  * **AWS Lambda function:** Containing the core logic for processing form data.
  * **AWS SNS Topic:** For asynchronous messaging and further data handling.

-----

## 👤 Author

Built and maintained by [@omerteomim](https://github.com/omerteomim)

-----

