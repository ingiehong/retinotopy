function configSyncInput

global analogIN

analogIN = analoginput('nidaq','Dev1');
set(analogIN, 'SampleRate', 10000);
actualInputRate = get(analogIN, 'SampleRate');
addchannel(analogIN,[0 1]);
set(analogIN,'SamplesPerTrigger',inf); 
