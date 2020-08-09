# When Perception is stronger than Physics
Data and analysis for the **When Perception is stronger than Physics: Perceptual similarities rather than laws of physics govern the perception of interacting objects** manuscript.


## File format

### Gears experiment

* Participant: participant's ID
* Session: timestamp of the beginning of the experimental session
* Block: block index
* OnsetDelay: delay before the stimulus onset, seconds
* Condition: experimental condition/manipulation
* Distance: distance between edges of the gears in percentage of their size
* DisplayLeft: image used for the left gear
* DisplayRight: image used for the right gear
* Occlusion: width of the occluding rectange in percentage of gears' size 
* Percept: reported perception
* Time: onset of the perception

### Walker-on-the-ball experiment
* Participant: participant's ID
* Session: timestamp of the beginning of the experimental session
* Block: block index
* OnsetDelay: delay before the stimulus onset, seconds
* Condition: experimental condition/manipulation
* Distance: vertical distance between the objects, degrees
* Shift: horizontal distance between the objects, degrees
* SphereDisambiguation: strength of the stereo disambiguation cues for the sphere, degrees
* WalkerDisambiguation: strength of the stereo disambiguation cues for the walker, degrees 
* Percept: reported perception
* Time: onset of the perception

**Single object report only:**
* SphereBias: biased direction of  rotation for the sphere

#### Software Error folder
It contains data set with two maipulated gears instead of one.

#### Aborted due to headache
It contains data set for the participant, who's session was cut short but a migraine attack./

## License
All data (and associated content) is licensed under the [CC-By Attribution 4.0 International License](https://creativecommons.org/licenses/by/4.0/). All code is licensed
under the [MIT License](http://www.opensource.org/licenses/mit-license.php).