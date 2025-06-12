# @capgo/apple-intelligence

Adds support for Apple Intelligence for Capacitor

## Install

```bash
npm install @capgo/apple-intelligence
npx cap sync
```

## API

<docgen-index>

* [`createChat()`](#createchat)
* [`sendMessage(...)`](#sendmessage)
* [`getReadiness()`](#getreadiness)
* [`addListener('textFromAi', ...)`](#addlistenertextfromai-)
* [`addListener('aiFinished', ...)`](#addlisteneraifinished-)
* [Interfaces](#interfaces)

</docgen-index>

<docgen-api>
<!--Update the source file JSDoc comments and rerun docgen to update the docs below-->

### createChat()

```typescript
createChat() => Promise<{ id: string; }>
```

**Returns:** <code>Promise&lt;{ id: string; }&gt;</code>

--------------------


### sendMessage(...)

```typescript
sendMessage(options: { chatId: string; message: string; }) => Promise<void>
```

| Param         | Type                                              |
| ------------- | ------------------------------------------------- |
| **`options`** | <code>{ chatId: string; message: string; }</code> |

--------------------


### getReadiness()

```typescript
getReadiness() => Promise<{ readiness: string; }>
```

**Returns:** <code>Promise&lt;{ readiness: string; }&gt;</code>

--------------------


### addListener('textFromAi', ...)

```typescript
addListener(eventName: 'textFromAi', listenerFunc: (event: TextFromAiEvent) => void) => Promise<{ remove: () => Promise<void>; }>
```

| Param              | Type                                                                            |
| ------------------ | ------------------------------------------------------------------------------- |
| **`eventName`**    | <code>'textFromAi'</code>                                                       |
| **`listenerFunc`** | <code>(event: <a href="#textfromaievent">TextFromAiEvent</a>) =&gt; void</code> |

**Returns:** <code>Promise&lt;{ remove: () =&gt; Promise&lt;void&gt;; }&gt;</code>

--------------------


### addListener('aiFinished', ...)

```typescript
addListener(eventName: 'aiFinished', listenerFunc: (event: AiFinishedEvent) => void) => Promise<{ remove: () => Promise<void>; }>
```

| Param              | Type                                                                            |
| ------------------ | ------------------------------------------------------------------------------- |
| **`eventName`**    | <code>'aiFinished'</code>                                                       |
| **`listenerFunc`** | <code>(event: <a href="#aifinishedevent">AiFinishedEvent</a>) =&gt; void</code> |

**Returns:** <code>Promise&lt;{ remove: () =&gt; Promise&lt;void&gt;; }&gt;</code>

--------------------


### Interfaces


#### TextFromAiEvent

| Prop         | Type                |
| ------------ | ------------------- |
| **`text`**   | <code>string</code> |
| **`chatId`** | <code>string</code> |


#### AiFinishedEvent

| Prop         | Type                |
| ------------ | ------------------- |
| **`chatId`** | <code>string</code> |

</docgen-api>
