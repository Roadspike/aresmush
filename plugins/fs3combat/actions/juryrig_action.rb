module AresMUSH
    module FS3Combat
        class JuryrigAction < CombatAction
            
            def prepare
                name = self.action_args
                if (!name || name.blank?)
                    return "You must specify a vehicle to juryrig."
                end

                vehicle = self.combat.find_vehicle_by_name(name)
                if (!vehicle)
                    return "That's not a vehicle."
                end

                pilot = vehicle.pilot
                if (!pilot)
                    return "There is no pilot in that vehicle."
                end
                                
                wound = FS3Combat.worst_treatable_wound(vehicle)
                if (!wound)
                    return "That vehicle does not have any repairable damage."
                end                
        
                if (pilot != self.combatant && !pilot.is_passing?)
                    return t('fs3combat.patient_must_pass')
                end

                self.target = vehicle
                return nil
            end
            
            def print_action
                "#{self.combatant.name} will juryrig #{self.action_args} this turn."
            end
            
            def print_action_short
                "Juryrig #{self.action_args}"
            end
            
           def resolve
                    tech_model = self.combatant
                    vehicle_model = self.combat.find_vehicle_by_name(self.action_args)
                    pilot_model = vehicle_model.pilot

                    if (!wound)
                       return "#{tech_model.name} tried to repair #{vehicle_model.name} but it has no repairable damage."
                    end
       
                    skill = FS3Combat.juryrig_skill 
       
                    roll = tech_model.roll_ability("Technician")
                    successes = roll[:successes]

                    if (successes <= 0)
                       return "#{tech_model.name} failed to repair #{pilot_model.name}."
                    end
       
                    self.combat.log "Juryrig: #{tech_model.name} repairing #{pilot_model.name}: #{roll}"

                    FS3Combat.heal(wound, 1)
                        "#{tech_model.name} successfully repaired #{pilot_model.name} worst damage."
                    FS3Combat.check_for_unko(pilot_model)
                      if (!self.combatant.is_npc?)
                  
                    Achievements.award_achievement(self.combatant.associated_model, "fs3_juryrigged")  
               end
           end
        end
    end
end
