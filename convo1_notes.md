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
  - some sort of classification needed.  Maybe SVM, mayble CNN (but would we have enough data)?
  
# 1 min segment scripts
## time yourself!

Anthony:  what methods do we have now?  pics of them? how we want to have this functionality but with pics from smartphones. 

Elijah: So this past summer I was working at National Institute of Sandarts and Technology and I was talking to one of the researchers there and he was telling me how there is currently a lot of work done in the private sector to develop software like this, that is able to  take finger prints from cell phone cameras, so it is a very hot topic right now.  So the reason that we see this strong push for algorithms able to take prints is that, apperently officers would like the ability to take finger prints infeild. But the issue is, it is way too combersome to run arround with a bulky fingerprint scanner, especially because their jobs require a lot of running around and even life or death situations, they don't want this machine holding them back. Also, it may be too hard to get the people that they want to print to cooperate through the scanning proccess.  But the thing is, everyone that is infeild already has or can easily have access to a smartphone, which is not too bulky and can quickly take a photo without as much need for cooperation. So just to wrap up my part, we are interested in persuing this project, not only because it gives us the ability to excersize a lot of what we have learned in class, but also because of its interesting applications to law enforcement.

Terrance:
