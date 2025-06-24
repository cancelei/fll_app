---
trigger: always_on
---

Here is the **Rails developer-focused project brief** reworked for **ERB with partials** (no Phlex), and including **WebRTC implementation guidelines within a dedicated service object following best practices**:

---

# 📄 Project Brief: Mobile-First Spoken English Grammar Feedback App (Rails + WebRTC + Tailwind + PostgreSQL)

## 1. Problem Summary

**User Pain:**
English learners struggle with **grammar mistakes when speaking**, especially in **professional work settings**.
They don’t need full fluency—just confidence and clear grammar during small talk, meetings, and remote work chats.

**Top User Problems Today:**

* No **targeted grammar feedback** when speaking
* **Repetitive grammar mistakes** with no way to track or retry
* Most tools focus on **pronunciation or full dialogues**, not **grammar correction only**

**MVP Scope:**

* Focus only on **grammar corrections** for these error types:

  * ✅ Verb tense
  * ✅ Word order
  * ✅ Subject-verb agreement

---

## 2. Solution Overview (Rails App with WebRTC Support)

### Rails Stack Setup:

```bash
rails new my_app -d postgresql --css tailwind --javascript esbuild
```

* **Views:** Standard **ERB templates**, reusable via Rails **partials**.
* **Frontend:** **Tailwind CSS** for mobile-first responsive design.
* **Backend:** **PostgreSQL**, **ActiveRecord models**, **service objects**, **concerns** where appropriate.
* **Dynamic UI:** **Hotwire (Turbo/Stimulus)** for form submissions, navigation, and progressive updates.
* **Audio Capture:**
  Implement **WebRTC-based voice recording** inside a **dedicated service layer**, with a **JavaScript Stimulus controller** for initiating the capture, sending the audio blob, and handling user permissions.

---

## 3. WebRTC Technical Requirements

| Area                         | Implementation                                                                                                                                                    |
| ---------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Audio Capture (Frontend)** | Use WebRTC via `MediaRecorder` API (browser-native). Controlled by **Stimulus controller (app/javascript/controllers/recording\_controller.js)**.                 |
| **Audio Upload**             | After recording, send audio Blob (or converted to Base64 / binary) via Turbo Stream or direct `POST` to Rails backend.                                            |
| **Service Layer (Rails)**    | Create a **`services/audio_processing_service.rb`** class responsible for handling audio uploads, storing in **ActiveStorage**, and triggering transcription job. |
| **Storage**                  | Use **ActiveStorage (PostgreSQL or S3 backend)** for recorded audio files.                                                                                        |
| **Security**                 | Implement **CSRF protection**, **Content-Type checking**, and validate audio MIME types (`audio/webm`, `audio/ogg`, etc.).                                        |
| **Error Handling**           | Rescue common WebRTC issues (e.g., mic permissions denied) via **Stimulus UI messages** and **Rails flash alerts**.                                               |

---

## 4. API Contract (Grammar Correction Service)

When Rails submits the transcript for grammar correction:

**Example Request:**

```json
{
  "user_response": "I am work here since 2021",
  "context_prompt": "How long have you been with your company?"
}
```

**Expected JSON Response:**

```json
{
  "transcript_with_highlights": "I <error>am work</error> here since 2021",
  "corrections": [
    {
      "error_type": "verb-tense",
      "mistake": "am work",
      "correction": "have been working",
      "tip": "Use present perfect continuous for ongoing past actions"
    }
  ],
  "grammar_score": 4,
  "fluency": "fair",
  "overall_feedback": "Good effort! Watch your verb tenses."
}
```

**Implementation Tip:**
Wrap the external API call in a Rails **Service Object**:
`app/services/grammar_correction_service.rb`

---

## 5. Rails Models (ActiveRecord)

| Model                 | Purpose                                                            |
| --------------------- | ------------------------------------------------------------------ |
| `Prompt`              | Speaking scenarios/questions                                       |
| `UserResponse`        | User’s spoken attempt, transcript, ActiveStorage audio attachment  |
| `Correction`          | Linked to UserResponse, holds error type, mistake, correction, tip |
| `MistakeJournalEntry` | Aggregated user mistake counts                                     |

---

## 6. Key Rails Features by App Section

| Area                 | Rails Implementation                                                                             |
| -------------------- | ------------------------------------------------------------------------------------------------ |
| **Speaking Flow**    | Stimulus controller → WebRTC record → Turbo Frame form submit → Create UserResponse              |
| **History View**     | ERB partials → List paginated UserResponses with link to show audio, transcript, and corrections |
| **Mistake Journal**  | ActiveRecord aggregation → Partial per error type                                                |
| **Prompt Rotation**  | Model scope or service → Random or tag-filtered prompt                                           |
| **Audio Management** | ActiveStorage for uploads + streaming playback                                                   |

---

## 7. Main User Flows (Use Cases)

| Use Case        | Flow                                                         |
| --------------- | ------------------------------------------------------------ |
| Practice Prompt | User sees prompt → Records → Submits → Sees correction       |
| Review History  | User views past responses → Replays audio → Reviews feedback |
| Mistake Journal | User checks common mistakes → Taps to retry related prompts  |
| Admin Analytics | Product team checks aggregated mistakes for insights         |

---

## 8. Definition of Done ✅

**MVP Must-Haves:**

* 🎤 Speaking practice with WebRTC recording + audio upload
* 📝 Grammar correction API integration + UI error highlights
* 📋 History: View previous attempts with audio + corrections
* 📈 Mistake Journal: Aggregated by error type
* 🗄️ Interaction logging: Prompt, transcript, correction, audio (for internal reporting)

**Optional / Future (Nice-to-Have):**

* UI language preference (full target language or mixed local language)
* Error reduction analytics over time
* Prompt tags + filter by workplace themes
* Simple visualizations (e.g., chart.js or rails-chartkick)

---

## 9. Architectural Notes

* **Service Objects:**
  For grammar API calls, audio processing, prompt selection.

* **Stimulus Controllers:**
  For **recording**, **UI feedback on errors**, and **file upload progress**.

* **ERB Views:**
  Keep **views clean and DRY** by leveraging **partials for repeated UI blocks** (e.g., prompt card, correction list, history item, mistake type summary).

* **Security:**
  Sanitize all incoming parameters. Validate content types. Rate-limit external API calls.

---

## 10. No-Go Areas (This Phase ❌)

| Feature                             | Reason       |
| ----------------------------------- | ------------ |
| Pronunciation feedback              | Not in scope |
| Full AI chat dialogues              | Not in scope |
| Real-time correction while speaking | Future       |
| Non-speaking grammar drills         | Not in scope |

---

Let me know if you want me to draft the initial **Rails models, migrations, and service object skeletons for WebRTC handling and grammar correction** next.
