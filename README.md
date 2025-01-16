# README
# upwork-google-ads-poc

Lightweight app - proof of concept to integrate GoogleAdsAPI to fetch/create Campaigns, AdGroups &amp; Ads

# Google Ads Account Setup Instructions

## 1. Create a Production Manager Account on Google Ads
1. **Sign Up for a Manager Account:**
   - Go to the [Google Ads Manager Account Signup](https://ads.google.com/intl/en_in/home/tools/manager-accounts/) page.
   - Click **Start Now** and sign in with a Google account.
   - Provide details for the account, including:
     - Account name
     - Billing country
     - Time zone
     - Currency
   - Accept the terms and conditions and click **Create Account**.

2. **Set Up Billing:**
   - Navigate to **Tools & Settings > Billing > Billing Settings**.
   - Select a payment method and complete the billing setup.
   - Ensure that the account is active by associating it with valid payment information.

---

## 2. Obtain a Developer Token
1. **Enable API Access:**
   - Log into your **Google Ads Manager Account**.
   - Go to **Tools & Settings > Setup > API Center**.
   - Under the **API Center**, locate the section for obtaining a **Developer Token**.

2. **Apply for a Developer Token:**
   - Fill in the required details for your application:
     - Indicate whether the token will be used for internal purposes or third-party app development.
     - Provide a detailed explanation of your app and how you plan to use the API.
   - Submit the application.

3. **Review and Approval:**
   - Google will review your request. Ensure the explanation is clear, professional, and complies with their terms.
   - Once approved, you’ll receive a **Test Token** initially. To activate it for production, follow Google’s verification steps, including completing their API compliance review if required.

---

## 3. Create a Test Manager and Test Client Account
### 3.1. Create a Test Manager Account
1. **Log Into Google Ads API Test Accounts Section:**
   - Go to the [Test Accounts Documentation](https://developers.google.com/google-ads/api/docs/testing/test-accounts).
   - Ensure you are logged into the **Production Manager Account** with API access.

2. **Request a Test Manager Account:**
   - Navigate to the **Google Ads API Test Accounts Request Form**.
   - Provide your **Production Manager Account ID** and submit the request.

3. **Activate the Test Manager Account:**
   - Once approved, Google will provide access to a Test Manager Account.

### 3.2. Create a Test Client Account
1. **Log Into the Test Manager Account:**
   - Use the Test Manager Account credentials provided by Google.
   - Navigate to **Accounts > Create New Account**.

2. **Create a Test Client Account:**
   - Set up a new client account under the Test Manager Account by filling in:
     - Account name
     - Billing country
     - Time zone
     - Currency
   - Skip billing information, as test accounts do not require payment setup.

---

## 4. Associate Test Accounts with the Production Account
1. **Grant Access to the Production Manager Account:**
   - In the **Test Manager Account**, navigate to **Account Access** under **Tools & Settings**.
   - Click **Add Users** and invite the Production Manager Account using its email address.
   - Assign the appropriate role (e.g., **Admin** or **Standard**).

2. **Accept the Invitation:**
   - Log into the **Production Manager Account** and accept the invitation to manage the Test Manager Account.

3. **Repeat for the Test Client Account:**
   - Log into the Test Client Account.
   - Grant access to the Production Manager Account using the same steps.

---

## 5. Verify Production Account Association
- Log into the **Production Manager Account** and confirm that it has access to:
  - The Test Manager Account.
  - The Test Client Account under the Test Manager Account.

---

## 6. Enter Credentials
- After completing the above setup, navigate back to the [Dashboard](<%= root_path %>). 
  Here, you'll find options to verify that your developer token and manager ID are correctly configured. 
  Follow the on-screen instructions to ensure successful integration.

---
