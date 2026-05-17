# Mortgage Application Management API (Architectural Demo)

This is a backend demonstration of a multi-tenant Ruby on Rails 8 JSON API service built to manage mortgage applications, validate customer account access, and run a safe, concurrent multi-stage background underwriting pipeline.

---

## 🏗️ Architectural Overview & Data Flow

This application is split into two distinct execution workflows to balance rapid customer feedback with high-integrity database persistence.

### ⚡ Instant Stateless Affordability Workflow
* **Open Client Check**: Prospective users can access an open endpoint (`POST /api/v1/affordability_assessments`) to instantly test their financial profile against the bank's lending rules without creating an account or hitting the database. The parameters are passed directly to an isolated pure-Ruby calculation engine (`AffordabilityCalculator`) and return a structured JSON evaluation within milliseconds.

### 🔄 Multi-Stage Asynchronous State Machine Workflow
1. **`new`**: The baseline state automatically assigned when a logged-in customer creates an application via the API.
2. **`MortgageProcessStarterJob`**: A scheduled worker that polls `new` applications using model-level getters (`.new_mortgage_applications`). It evaluates data via the `AffordabilityCalculator`. If the application fails lending thresholds, it transitions to `declined` (end of process). If it passes, it moves to `under_process`.
3. **`PropertyValuationRequestJob`**: Sweeps for `under_process` records, simulates an outbound third-party valuation API request, and updates the status to `sent`.
4. **`PropertyValuationResultFetcherJob`**: A blueprint loop designed to poll an external vendor framework using unique application identifiers. If no response payload is available, it remains in the `sent` state. If approved, it moves to `likely_approved`; if rejected, it transitions to `unlikely_approved`.

---

## 🚀 Setup & Execution Instructions

### Prerequisites
* Ruby `3.3.5`
* Rails `8.1.3`
* SQLite3 / HTTPie

### 1. Installation & Dependency Compilation
Clone the repository into a fresh location and initialize local environment dependencies:
```bash
bundle install
```

### 2. Database Creation & Seeding
Prepare your local SQLite schema tables and seed the default testing customer login credentials:
```bash
bundle exec rails db:migrate
bundle exec rails db:seed
```
*The seed task configures a baseline client account: **`test@example.com`** / **`password123`***

### 3. Launching the API Server
Boot your backend endpoint server explicitly on port `3001` to ensure it never collides with a traditional port `3000` frontend client:
```bash
bin/rails server -p 3001
```

### 4. Running the Test Suite
Execute the comprehensive automated testing framework (includes isolated service math specs, validation inclusions, namespaced session controllers, and end-to-end integration tests):
```bash
bundle exec rspec
```

### 5. Compiling the Background Cron Schedule
Write your automated background scheduler tracks directly into your Mac machine's internal system daemon using the `Whenever` engine:
```bash
bundle exec whenever --update-crontab
```

---

## 📝 Design & Reflection Answers

### 1. Key Design Decisions
* **Decoupled Stateless vs. Stateful Logic**: Isolated the primary core math rules logic (`AffordabilityCalculator`) into a pure Ruby service object that has zero dependencies on ActiveRecord. This ensures that the math can run instantly on open endpoints for prospective guests without touching the database, while still allowing stateful models to call it smoothly via background workers.
* **Encapsulated Object-Oriented State Transitions**: Avoided writing raw string mutations inside controller or worker actions. Instead, built classic class getters (e.g., `.under_process`) and explicit instance setters (e.g., `#mark_as_sent!`) directly on the model. This creates clean, self-documenting Ruby code and keeps state transitions secure.
* **Pessimistic Concurrency Controls**: Integrated full database-level row locking (`with_lock`) across all background processing worker blocks. This ensures complete multi-threaded data protection and isolates records dynamically, guarding against data-race mutations if multiple background processes poll data entries at the exact same fraction of a second.
* **Hybrid Session Middleware Selection**: Manually restored `ActionDispatch::Cookies` and `CookieStore` middleware stacks into an otherwise stripped `api_only = true` configuration. This enables full native access to secure `current_user` and `authenticate_user!` helper macros while maintaining an optimized JSON API layout.
* **Tiered Test Isolation**: Configured a clear three-tier testing strategy. Used **Unit Service Specs** to test borderline mathematical rules (e.g., boundary calculations at exactly 90% LTV), **Isolated Request Specs** with stubs to verify API parameter gates independently, and **Unstubbed Integration Specs** inside a dedicated folder to ensure full-stack data flows successfully from HTTP down to SQLite.

### 2. Scaling Consideration (Handling Significantly Higher Load / High Pressure)
If this implementation needed to operate under high pressure and significantly higher load, the first things to change would be the **database engine** and the **background queuing backend**:
* **Migrate from SQLite to PostgreSQL**: SQLite locks the entire database file during transactional writes, which would create severe bottlenecks under heavy application submission volume. Moving to a client-server relational database like PostgreSQL allows for high concurrency and row-level locking.
* **Replace Async ActiveJob Memory Queuing with Redis and Sidekiq/Solid Queue**: Currently, ActiveJob runs in-memory, which is not suitable for high load because jobs are lost if the server restarts. Shifting to a persistent multi-threaded worker stack backed by Redis (Sidekiq) or database tables (Solid Queue) ensures background tasks can scale independently across multiple worker nodes without blocking the primary Rails web workers.

### 3. Trade-offs
* **Cookie Sessions vs. JWT Tokens**: Selected cookie-based authentication over JSON Web Tokens (JWT). JWTs offer pure statelessness but add development overhead (requiring token database blacklists and specialized frontend header interceptors). Restoring cookie middleware kept the demonstration implementation streamlined and lean.
* **Blueprinted External Integrations**: Maintained the Stage 2 and Stage 3 property valuation components as clean, logged code mock blueprints rather than writing live network code. Handling real external connections requires complex integration logic, connection timeouts, and circuit-breaker designs, which were left out to focus purely on the structural flow.

### 4. Prioritized Next Steps & Product Roadmap

If granted more engineering cycles, future tasks would be executed in the following order of priority to advance the platform from an architectural demonstration to a complete end-to-end product:

#### 🖥️ Priority 1: React Frontend Integration & Session Architecture (High Priority)
*   **Decoupled Frontend Connection**: Build the companion React/Vite user interface to consume these endpoints. 
*   **Robust Session Management**: Configure Cross-Origin Resource Sharing (`rack-cors`) and update our custom `SessionsController` to securely pass cross-domain cookies or implement a bearer token system (`devise-jwt`). This allows the separate frontend to read the authenticated session cookie securely and maintain the `current_user` state across views.

#### ⚙️ Priority 2: Manual Admin Finalizer Job (High-Medium Priority)
*   **MortgageFinalizerJob**: Introduce a concluding background task that targets applications sitting in intermediate states (`likely_approved` or `likely_declined`). This job automatically surfaces records to an internal dashboard where a human administrator or underwriter can review the file, add their notes, and manually click to finalize the state to either `approved` or `declined`. This completes the absolute end-to-end flow of the application.

#### 🧪 Priority 3: Test Suite Refactoring & Maintainability (Medium Priority)
*   **Integrate FactoryBot**: Replace manual `MortgageApplication.create!` loops inside test files with dynamic factories. This abstracts test data generation, speeds up the suite, and prevents tests from breaking if table schemas change in the future.

