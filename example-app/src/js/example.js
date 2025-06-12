import { AppleIntelligence } from '@capgo/apple-intelligence';

window.testEcho = () => {
    const inputValue = document.getElementById("echoInput").value;
    AppleIntelligence.echo({ value: inputValue })
}
