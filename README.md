# @capgo/llm

<a href="https://capgo.app/"><img src='https://raw.githubusercontent.com/Cap-go/capgo/main/assets/capgo_banner.png' alt='Capgo - Instant updates for capacitor'/></a>

<div align="center">
  <h2><a href="https://capgo.app/?ref=plugin"> ➡️ Get Instant updates for your App with Capgo 🚀</a></h2>
  <h2><a href="https://capgo.app/consulting/?ref=plugin"> Fix your annoying bug now, Hire a Capacitor expert 💪</a></h2>
</div>

Adds support for LLM locally runned for Capacitor

It uses Apple Intelligence (default) or custom models via LLM.swift in iOS and tasks-genai in Android

## Installation

```bash
npm install @capgo/llm
npx cap sync
```

### iOS Additional Setup for Custom Models

If you want to use custom models on iOS (not just Apple Intelligence), you need to add LLM.swift dependency:

**Using Swift Package Manager (Recommended):**
1. In Xcode, go to File → Add Package Dependencies
2. Add: `https://github.com/eastriverlee/LLM.swift`
3. Select version 1.0.0 or later

**Using CocoaPods:**
Since LLM.swift is not published to CocoaPods, add it directly in your Podfile:
```ruby
pod 'LLM.swift', :git => 'https://github.com/eastriverlee/LLM.swift.git'
```

## Adding a Model to Your App

### iOS

On iOS, you have two options:

1. **Apple Intelligence (Default)**: Uses the built-in system model (requires iOS 26.0+)
2. **Custom Models**: Use your own GGUF format models via LLM.swift

#### Using Custom Models on iOS

1. **Add a GGUF model to your app**:
   - Download a GGUF format model (e.g., from Hugging Face)
   - Add it to your Xcode project
   - Ensure it's included in "Copy Bundle Resources" build phase

2. **Set the model path**:

```typescript
import { CapgoLLM } from '@capgo/llm';

// Load a model from the app bundle
await CapgoLLM.setModelPath({ path: 'mistral-7b-instruct-v0.2.Q4_K_M.gguf' });

// Or use an absolute path
await CapgoLLM.setModelPath({ path: '/path/to/model.gguf' });

// Now you can create chats and send messages
const chat = await CapgoLLM.createChat();
```

### Android

For Android, you need to include a compatible LLM model in your app. The plugin uses MediaPipe's tasks-genai, which supports various model formats.

1. **Download a compatible model**: Download a model file (e.g., Gemini Nano or other MediaPipe-compatible models) from Google's model repository.

2. **Add the model to your app's assets**:
   - Place the model file in your app's `android/app/src/main/assets/` directory
   - Or store it in your app's files directory

3. **Set the model path**:

```typescript
import { CapgoLLM } from '@capgo/llm';

// If model is in assets folder
await CapgoLLM.setModelPath({ path: '/android_asset/your_model.bin' });

// If model is in app's files directory
await CapgoLLM.setModelPath({ path: '/data/data/com.yourapp/files/your_model.bin' });

// Now you can create chats and send messages
const chat = await CapgoLLM.createChat();
```

## Usage Example

```typescript
import { CapgoLLM } from '@capgo/llm';

// Check if LLM is ready
const { readiness } = await CapgoLLM.getReadiness();
console.log('LLM readiness:', readiness);

// Set a custom model (optional - uses system default if not called)
// iOS: Use a GGUF model from bundle or path
// Android: Use a MediaPipe model from assets or files
await CapgoLLM.setModelPath({ 
  path: Platform.isIOS ? 'llama-2-7b-chat.Q4_K_M.gguf' : '/android_asset/gemini-nano.bin' 
});

// Create a chat session
const { id: chatId } = await CapgoLLM.createChat();

// Listen for AI responses
CapgoLLM.addListener('textFromAi', (event) => {
  console.log('AI:', event.text);
});

// Listen for completion
CapgoLLM.addListener('aiFinished', (event) => {
  console.log('AI finished responding to chat:', event.chatId);
});

// Send a message
await CapgoLLM.sendMessage({
  chatId,
  message: 'Hello! How are you today?'
});
```

## API

<docgen-index>

* [`createChat()`](#createchat)
* [`sendMessage(...)`](#sendmessage)
* [`getReadiness()`](#getreadiness)
* [`addListener('textFromAi', ...)`](#addlistenertextfromai-)
* [`addListener('aiFinished', ...)`](#addlisteneraifinished-)
* [`setModelPath(...)`](#setmodelpath)
* [Interfaces](#interfaces)

</docgen-index>

<docgen-api>
<!--Update the source file JSDoc comments and rerun docgen to update the docs below-->

LLM Plugin interface for interacting with on-device language models

### createChat()

```typescript
createChat() => Promise<{ id: string; instructions?: string; }>
```

Creates a new chat session

**Returns:** <code>Promise&lt;{ id: string; instructions?: string; }&gt;</code>

--------------------


### sendMessage(...)

```typescript
sendMessage(options: { chatId: string; message: string; }) => Promise<void>
```

Sends a message to the AI in a specific chat session

| Param         | Type                                              | Description                       |
| ------------- | ------------------------------------------------- | --------------------------------- |
| **`options`** | <code>{ chatId: string; message: string; }</code> | - The chat id and message to send |

--------------------


### getReadiness()

```typescript
getReadiness() => Promise<{ readiness: string; }>
```

Gets the readiness status of the LLM

**Returns:** <code>Promise&lt;{ readiness: string; }&gt;</code>

--------------------


### addListener('textFromAi', ...)

```typescript
addListener(eventName: 'textFromAi', listenerFunc: (event: TextFromAiEvent) => void) => Promise<{ remove: () => Promise<void>; }>
```

Adds a listener for text received from AI

| Param              | Type                                                                            | Description                         |
| ------------------ | ------------------------------------------------------------------------------- | ----------------------------------- |
| **`eventName`**    | <code>'textFromAi'</code>                                                       | - Event name 'textFromAi'           |
| **`listenerFunc`** | <code>(event: <a href="#textfromaievent">TextFromAiEvent</a>) =&gt; void</code> | - Callback function for text events |

**Returns:** <code>Promise&lt;{ remove: () =&gt; Promise&lt;void&gt;; }&gt;</code>

--------------------


### addListener('aiFinished', ...)

```typescript
addListener(eventName: 'aiFinished', listenerFunc: (event: AiFinishedEvent) => void) => Promise<{ remove: () => Promise<void>; }>
```

Adds a listener for AI completion events

| Param              | Type                                                                            | Description                           |
| ------------------ | ------------------------------------------------------------------------------- | ------------------------------------- |
| **`eventName`**    | <code>'aiFinished'</code>                                                       | - Event name 'aiFinished'             |
| **`listenerFunc`** | <code>(event: <a href="#aifinishedevent">AiFinishedEvent</a>) =&gt; void</code> | - Callback function for finish events |

**Returns:** <code>Promise&lt;{ remove: () =&gt; Promise&lt;void&gt;; }&gt;</code>

--------------------


### setModelPath(...)

```typescript
setModelPath(options: { path: string; }) => Promise<void>
```

Sets the model path for custom models
- iOS: Path to a GGUF model file (in bundle or absolute path)
- Android: Path to a MediaPipe model file (in assets or files directory)

| Param         | Type                           | Description                    |
| ------------- | ------------------------------ | ------------------------------ |
| **`options`** | <code>{ path: string; }</code> | - The model path configuration |

--------------------


### Interfaces


#### TextFromAiEvent

Event data for text received from AI

| Prop         | Type                | Description              |
| ------------ | ------------------- | ------------------------ |
| **`text`**   | <code>string</code> | The text content from AI |
| **`chatId`** | <code>string</code> | The chat session ID      |


#### AiFinishedEvent

Event data for AI completion

| Prop         | Type                | Description                       |
| ------------ | ------------------- | --------------------------------- |
| **`chatId`** | <code>string</code> | The chat session ID that finished |

</docgen-api>
