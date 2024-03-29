%autolabel2
classdef autolabel_2_HandDetection < vision.labeler.AutomationAlgorithm
    properties(Constant)
        Name = 'Hand Detection';
        Description = 'Hand Auto Labeling';
        UserDirections = {...
            ['Automation algorithms are a way to automate manual labeling ' ...
            'tasks. This AutomationAlgorithm is a template for creating ' ...
            'user-defined automation algorithms. Below are typical steps' ...
            'involved in running an automation algorithm.'], ...
            ['Run: Press RUN to run the automation algorithm. '], ...
            ['Review and Modify: Review automated labels over the interval ', ...
            'using playback controls. Modify/delete/add ROIs that were not ' ...
            'satisfactorily automated at this stage. If the results are ' ...
            'satisfactory, click Accept to accept the automated labels.'], ...
            ['Change Settings and Rerun: If automated results are not ' ...
            'satisfactory, you can try to re-run the algorithm with ' ...
            'different settings. In order to do so, click Undo Run to undo ' ...
            'current automation run, click Settings and make changes to ' ...
            'Settings, and press Run again.'], ...
            ['Accept/Cancel: If results of automation are satisfactory, ' ...
            'click Accept to accept all automated labels and return to ' ...
            'manual labeling. If results of automation are not ' ...
            'satisfactory, click Cancel to return to manual labeling ' ...
            'without saving automated labels.']};
    end
    
    properties
        AllCategories = {'background'};
        HandName
        count
    end
    
    methods
%         function isValid = checkLabelDefinition(algObj, labelDef)
%             disp(['Executing checkLabelDefinition on label definition "' labelDef.Name '"'])
%             if (strcmpi(labelDef.Name, 'A') && labelDef.Type == labelType.Rectangle)
%                 isValid = true;
%                 algObj.AName = labelDef.Name;
%                 algObj.AllCategories{end+1} = labelDef.Name;
%             end
%         end

        function isValid = checkLabelDefinition(~, labelDef)
            
            % Only labels for rectangular ROI's are considered valid.
            isValid = labelDef.Type == labelType.Rectangle;
            
        end
        
        function isReady = checkSetup(algObj)
            disp('Executing checkSetup')
            isReady = ~isempty(algObj);     
        end
        
        function settingsDialog(algObj)
            disp('Executing settingsDialog')
        end
    end
    
    methods
        function initialize(algObj, I)
            disp('Executing initialize on the first image frame')
        end
        
        function autoLabels = run(algObj, I)
            disp('Executing run on image frame')
            [labelCord, label] = autolabel_1_objectlabel(I, algObj);                
            autoLabels.Name = char(label);
            autoLabels.Type = labelType('Rectangle');
            autoLabels.Position = labelCord;               
            algObj.count = algObj.count+1;
        end
        
        function terminate(algObj)
            disp('Executing terminate')
        end
    end
end
