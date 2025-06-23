extends CharacterBody2D

# This is an example of how to use Beehave with the Acids Joe boss

@onready var behavior_tree = $BehaviorTree

func _ready():
    # The behavior tree will automatically start running
    pass

# Example structure of a behavior tree for Acids Joe:
#
# BehaviorTree
# └── Selector (Phase Selector)
#     ├── Sequence (Phase 1)
#     │   ├── Condition (IsPhase1)
#     │   └── Selector (Phase 1 Actions)
#     │       ├── Sequence (Attack Player)
#     │       │   ├── Condition (PlayerInRange)
#     │       │   └── Action (PerformAttack)
#     │       ├── Sequence (Chase Player)
#     │       │   ├── Condition (PlayerVisible)
#     │       │   └── Action (ChasePlayer)
#     │       └── Action (Wander)
#     └── Sequence (Phase 2)
#         ├── Condition (IsPhase2)
#         └── Selector (Phase 2 Actions)
#             ├── Sequence (Psychedelic Attack)
#             │   ├── Condition (CanUsePsychedelicAttack)
#             │   └── Action (PerformPsychedelicAttack)
#             ├── Sequence (Special Attack)
#             │   ├── Condition (SpecialAttackReady)
#             │   └── Action (PerformSpecialAttack)
#             └── Sequence (Basic Attack)
#                 ├── Condition (PlayerInRange)
#                 └── Action (PerformBasicAttack)

# Example condition class
class IsPhase1 extends BeehaveCondition:
    func tick(actor, blackboard):
        if actor.current_phase == 1:
            return SUCCESS
        return FAILURE

# Example action class
class PerformAttack extends BeehaveAction:
    func tick(actor, blackboard):
        actor._perform_attack()
        return SUCCESS