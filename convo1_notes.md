# Notes from Bihall

1) **what? -> Anthony**
  - IP algorithm, determine if a print is already in the database
  - takes in prints taken on smartphones.  
  - Not super high resolution. Want to generalize to all smartphones
  
2) **why? -> Elijah**
  - Important for infield officers
  - People that are caught not going to cooperate
  - Too hard to carry around print scanner, need portable
  - Curently stuff being done at NIST on the topic.  Topic of intrest

3) **How? -> Terrance**
  - SQL database
  - Need to build our dataset by taking photos of students' prints, different lighting and conditions
  - Preprocess -> IP to turn the photos into something usable
  - some sort of classification needed.  Maybe multicalss SVM, maybe Multinom Logistic regreesion, mayble CNN (but would we have enough data)?
  
# 1 min segment scripts
## time yourself!

Anthony:  what methods do we have now?  pics of them? how we want to have this functionality but with pics from smartphones. Issue of resolution, how it can varry between smartphones so we want to generallize to multiple smartphones and resolutions. So ultimately, we want to take these pics, run an IP algorithm that we develop, and then checkl to see if the print already exists in the database/ match it to the person.

Elijah: So this past summer I was working at National Institute of Standards and Technology and I was talking to one of the researchers there and he actually told me that there is currently a lot of work being done in the private sector to develop software like this, that is able to take usable finger prints from cell phone cameras. And the reason that we see this strong push for algorithms able to take prints from a mobile device is that police officers would like the ability to take finger prints infeild and look the person up in a database to see their possible past criminal history. But the issue is, current finger printing technologies are often too cumbersome for officers to run around with, especially because their jobs may even involve even life or death situations they don't want a machine holding them back. Also, it may be too hard to get the people that they want to print to cooperate through the scanning process. But the thing is, everyone that is infeild already has or can easily have access to a smartphone, which is not too bulky and can quickly take a photo without as much need for cooperation. So to wrap up my part, we are interested in pursuing this project, not only because it gives us the ability to exercise a lot of what we have learned in class, but also because of its interesting applications to law enforcement.


Terrance:
