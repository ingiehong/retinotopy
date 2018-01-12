function playsound(file);

global pepconfig;

[y,fs,nb] = wavread(file);
soundsc(y,fs);
