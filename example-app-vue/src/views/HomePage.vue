<template>
  <ion-page>
    <ion-header :translucent="true">
      <ion-toolbar>
        <ion-title>Apple AI Chatbot</ion-title>
      </ion-toolbar>
    </ion-header>

    <ion-content :fullscreen="true" class="chat-content" ref="contentRef">
      <ion-refresher slot="fixed" @ionRefresh="refresh($event)">
        <ion-refresher-content></ion-refresher-content>
      </ion-refresher>

      <ion-header collapse="condense">
        <ion-toolbar>
          <ion-title size="large">Apple AI Chatbot</ion-title>
        </ion-toolbar>
      </ion-header>

      <ion-list>
        <!-- Dynamic messages -->
        <ion-item 
          v-for="message in messages" 
          :key="message.id" 
          :class="['message-item', message.isUser ? 'user-message' : 'ai-message']"
        >
          <div :class="['message-container', message.isUser ? 'user' : 'ai']">
            <!-- AI Avatar (only for AI messages) -->
            <div v-if="!message.isUser" class="ai-avatar">
              <svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 24 24">
                <path fill="currentColor" d="M9.376 22.08c-.32 0-.64-.07-.95-.21c-.73-.33-1.21-1-1.3-1.79l-.28-2.64l-2.62-.68c-.81-.21-1.41-.81-1.61-1.6s.04-1.6.64-2.16l1.93-1.8l-1.06-2.33c-.33-.73-.25-1.56.22-2.21c.49-.67 1.27-1.01 2.1-.91l2.79.33l1.32-2.36c.39-.7 1.1-1.13 1.9-1.15c.79-.04 1.54.36 1.97 1.03l1.48 2.32l2.74-.49c.81-.15 1.61.14 2.14.77c.52.62.66 1.44.37 2.19l-.93 2.43l2.01 1.66c.63.52.92 1.31.77 2.11s-.73 1.45-1.51 1.71l-2.6.83l-.11 2.6c-.04.8-.48 1.49-1.19 1.87c-.72.38-1.56.35-2.26-.07l-2.4-1.48l-2.28 1.6c-.39.27-.84.41-1.3.41zm-.97-4.23l.22 2.08c.04.37.31.53.43.58c.25.11.54.09.77-.07l1.75-1.23l-.59-.37c-.63-.38-1.3-.67-2.01-.86l-.55-.14zm5.88 1.28l1.85 1.14c.24.14.52.15.77.02c.11-.06.37-.24.39-.61l.08-2.05l-.73.23c-.7.23-1.36.55-1.96.97l-.41.28zm-6.05-2.88l1.1.28c.86.22 1.67.57 2.43 1.03l1.14.71l.94-.66c.72-.5 1.51-.9 2.36-1.17l1.25-.4l.04-.97c.04-.91.23-1.81.55-2.66l.42-1.1l-.8-.67c-.7-.58-1.3-1.26-1.78-2.01l-.68-1.06l-1.15.2c-.86.16-1.74.18-2.62.08l-1.36-.16l-.5.91c-.44.78-.99 1.5-1.65 2.11l-.91.85l.92 2.03c.03.07.05.15.06.23l.26 2.42zm-2.39-3.6l-1.55 1.45c-.28.26-.24.57-.21.7c.03.12.15.42.53.52l2.07.54l-.18-1.74l-.66-1.46zm13.83-.33l-.24.62c-.26.71-.42 1.45-.45 2.2l-.02.42l2.08-.67a.717.717 0 0 0 .25-1.24l-1.62-1.34zM6.186 7.24a.74.74 0 0 0-.61.31c-.07.1-.22.37-.07.7l.85 1.87l.54-.5c.54-.51 1-1.10 1.37-1.75l.21-.37l-2.18-.26zm10.61.06l.34.53c.4.62.89 1.18 1.47 1.66l.41.34l.75-1.95a.7.7 0 0 0-.12-.7a.74.74 0 0 0-.72-.26l-2.12.38zm-5.94-1.01l.75.09c.73.09 1.46.07 2.18-.06l.54-.1l-1.15-1.79c-.21-.32-.51-.34-.67-.34c-.13 0-.45.05-.64.38l-1.02 1.82z"/>
              </svg>
            </div>
            <!-- Message bubble -->
            <div :class="['message-bubble', message.isUser ? 'user-bubble' : 'ai-bubble']">
              <ion-label>
                <p>{{ message.text }}<span v-if="!message.isUser && !isTypingComplete(message)" class="typing-cursor">|</span></p>
              </ion-label>
            </div>
          </div>
        </ion-item>
      </ion-list>
    </ion-content>

    <!-- Message input area as footer -->
    <ion-footer>
      <ion-toolbar>
        <ion-item class="message-input-item">
          <ion-input 
            v-model="newMessage"
            placeholder="Type a message..." 
            class="message-input"
            @keyup.enter="sendMessage"
          ></ion-input>
          <ion-button 
            slot="end" 
            fill="solid" 
            shape="round" 
            @click="sendMessage"
            :disabled="!newMessage.trim()"
            class="send-button"
          >
            <ion-icon :icon="sendIcon" />
          </ion-button>
        </ion-item>
      </ion-toolbar>
    </ion-footer>
  </ion-page>
</template>

<script setup lang="ts">
import {
  IonContent,
  IonHeader,
  IonList,
  IonPage,
  IonRefresher,
  IonRefresherContent,
  IonTitle,
  IonToolbar,
  IonItem,
  IonLabel,
  IonInput,
  IonButton,
  IonIcon,
  IonFooter,
} from '@ionic/vue';
import { send } from 'ionicons/icons';
import { ref, nextTick, onMounted, onUnmounted } from 'vue';
import type { TextFromAiEvent } from '@capgo/apple-intelligence';
import { AppleIntelligence } from '@capgo/apple-intelligence';


interface Message {
  id: number;
  text: string;
  isUser: boolean;
  timestamp: Date;
  isComplete?: boolean;
}

const newMessage = ref('');
const sendIcon = send;
const contentRef = ref();
const chatId = ref<string>('');
const currentAiMessageId = ref<number | null>(null);
let listenerRemove: (() => Promise<void>) | null = null;

const messages = ref<Message[]>([
  {
    id: 1,
    text: "What is life?",
    isUser: true,
    timestamp: new Date(),
    isComplete: true
  },
  {
    id: 2,
    text: "life is fun!",
    isUser: false,
    timestamp: new Date(),
    isComplete: true
  }
]);

let messageIdCounter = 3;

const refresh = (ev: CustomEvent) => {
  setTimeout(() => {
    ev.detail.complete();
  }, 3000);
};

const scrollToBottom = async () => {
  await nextTick();
  if (contentRef.value) {
    contentRef.value.$el.scrollToBottom(300);
  }
};

const isTypingComplete = (message: Message) => {
  return message.isComplete !== false;
};

const handleAiResponse = (event: TextFromAiEvent) => {
  if (event.chatId !== chatId.value) return;
  
  // Find the current AI message being streamed
  if (currentAiMessageId.value !== null) {
    const messageIndex = messages.value.findIndex(m => m.id === currentAiMessageId.value);
    if (messageIndex !== -1) {
      // Update the message text with the streaming response
      messages.value[messageIndex].text = event.text;
      scrollToBottom();
      
      // If the response seems complete (you might need to adjust this logic based on how the AI signals completion)
      // For now, we'll consider it complete if it ends with punctuation
      if (event.text.match(/[.!?]$/)) {
        messages.value[messageIndex].isComplete = true;
        currentAiMessageId.value = null;
      }
    }
  }
};

const sendMessage = async () => {
  if (newMessage.value.trim() && chatId.value) {
    // Add user message
    const userMessage: Message = {
      id: messageIdCounter++,
      text: newMessage.value,
      isUser: true,
      timestamp: new Date(),
      isComplete: true
    };
    messages.value.push(userMessage);
    
    const messageText = newMessage.value;
    newMessage.value = '';
    
    // Scroll to bottom
    await scrollToBottom();
    
    // Create empty AI message for streaming response
    const aiMessage: Message = {
      id: messageIdCounter++,
      text: "",
      isUser: false,
      timestamp: new Date(),
      isComplete: false
    };
    messages.value.push(aiMessage);
    currentAiMessageId.value = aiMessage.id;
    
    await scrollToBottom();
    
    try {
      // Send message to AI
      await AppleIntelligence.sendMessage({
        chatId: chatId.value,
        message: messageText
      });
    } catch (error) {
      console.error('Error sending message to AI:', error);
      // Handle error - maybe show an error message
      const messageIndex = messages.value.findIndex(m => m.id === aiMessage.id);
      if (messageIndex !== -1) {
        messages.value[messageIndex].text = "Sorry, I encountered an error. Please try again.";
        messages.value[messageIndex].isComplete = true;
      }
      currentAiMessageId.value = null;
    }
  }
};

onMounted(async () => {
  try {
    // Create a new chat session
    const chat = await AppleIntelligence.createChat();
    chatId.value = chat.id;
    
    // Set up listener for AI responses
    const listener = await AppleIntelligence.addListener('textFromAi', handleAiResponse);
    listenerRemove = listener.remove;
    
    console.log('Apple Intelligence chat created:', chat.id);
  } catch (error) {
    console.error('Error initializing Apple Intelligence:', error);
  }
});

onUnmounted(async () => {
  // Clean up listener when component is destroyed
  if (listenerRemove) {
    await listenerRemove();
  }
});
</script>

<style scoped>
.chat-content {
  --padding-bottom: 0px;
}

.message-item {
  --padding-start: 0;
  --padding-end: 0;
  --inner-padding-end: 0;
  --inner-padding-start: 0;
  --min-height: auto;
}

.message-container {
  width: 100%;
  display: flex;
  padding: 8px 16px;
  margin: 4px 0;
}

.message-container.user {
  justify-content: flex-end;
}

.message-container.ai {
  justify-content: flex-start;
  align-items: flex-start;
  gap: 12px;
}

.message-bubble {
  max-width: 80%;
  padding: 12px 16px;
  border-radius: 18px;
  word-wrap: break-word;
}

.user-bubble {
  background-color: #007AFF;
  color: white;
  border-bottom-right-radius: 4px;
}

.ai-bubble {
  background-color: #F2F2F7;
  color: #000;
  border-bottom-left-radius: 4px;
}

.ai-avatar {
  flex-shrink: 0;
  width: 32px;
  height: 32px;
  border-radius: 16px;
  background-color: #E5E5EA;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #8E8E93;
  margin-top: 4px;
}

.message-bubble ion-label p {
  margin: 0;
  font-size: 16px;
  line-height: 1.4;
}

.typing-cursor {
  animation: blink 1s infinite;
  color: #007AFF;
  font-weight: bold;
}

@keyframes blink {
  0%, 50% { opacity: 1; }
  51%, 100% { opacity: 0; }
}

.message-input-item {
  --padding-start: 12px;
  --padding-end: 12px;
  --inner-padding-end: 0;
  --inner-padding-start: 0;
  --background: transparent;
}

.message-input {
  font-size: 16px;
}

.send-button {
  --padding-start: 12px;
  --padding-end: 12px;
  margin-left: 8px;
  height: 36px;
  width: 36px;
}

.send-button ion-icon {
  font-size: 18px;
}

.send-button[disabled] {
  opacity: 0.4;
}

ion-footer {
  --background: var(--ion-color-light);
}

ion-footer ion-toolbar {
  --background: transparent;
  --border-width: 1px 0 0 0;
  --border-color: var(--ion-color-medium);
}

/* Dark mode support */
@media (prefers-color-scheme: dark) {
  .ai-bubble {
    background-color: #2C2C2E;
    color: #FFFFFF;
  }
  
  .user-bubble {
    background-color: #007AFF;
    color: #FFFFFF;
  }
  
  .ai-avatar {
    background-color: #48484A;
    color: #8E8E93;
  }
  
  .message-bubble ion-label,
  .message-bubble ion-label p {
    color: #FFFFFF;
  }
  
  .message-input {
    color: #FFFFFF;
  }
  
  .message-input-item {
    --color: #FFFFFF;
  }
  
  ion-footer {
    --background: var(--ion-color-dark);
  }
  
  ion-footer ion-toolbar {
    --border-color: var(--ion-color-medium-shade);
  }
}
</style>

