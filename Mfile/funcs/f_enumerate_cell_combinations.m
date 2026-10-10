function output_matrix = f_enumerate_cell_combinations(input_cell)
    % 2024/12/4, version 1. Generated with Claude 3.5 Sonnet by Yamin
    % GENERATE_COMBINATIONS Recursively generates all combinations from various input types
    % 
    % Input:
    %   input_cell - A cell array containing different types of inputs 
    %                (cells, vectors, matrices, mixed types)
    % 
    % Output:
    %   output_matrix - A cell array with all possible combinations
    
    % Validate input
    if ~iscell(input_cell)
        error('Input must be a cell array');
    end
    
    % Normalize inputs to cell arrays
    normalized_inputs = cell(size(input_cell));
    for i = 1:length(input_cell)
        % Convert different input types to cell arrays
        current_input = input_cell{i};
        
        if iscell(current_input)
            % If already a cell, use as-is
            normalized_inputs{i} = current_input;
        elseif isnumeric(current_input) || islogical(current_input)
            % For numeric or logical arrays, convert to cell array
            normalized_inputs{i} = num2cell(current_input(:));
        elseif ischar(current_input) || isstring(current_input)
            % For strings, convert to cell array
            normalized_inputs{i} = cellstr(current_input);
        else
            % For other types, try to convert to cell
            try
                normalized_inputs{i} = num2cell(current_input);
            catch
                error('Unsupported input type in cell %d', i);
            end
        end
    end
    
    % Base case: if only one input, return it as a column
    if length(normalized_inputs) == 1
        output_matrix = normalized_inputs{1}(:);
        return;
    end
    
    % Recursive case
    % Split the input into first input and remaining inputs
    first_input = normalized_inputs{1};
    remaining_inputs = normalized_inputs(2:end);
    
    % Recursively generate combinations of remaining inputs
    sub_combinations = f_enumerate_cell_combinations(remaining_inputs);
    
    % Preallocate output cell array
    output_matrix = cell(length(first_input) * size(sub_combinations, 1), length(normalized_inputs));
    
    % Generate full combinations
    row_index = 1;
    for i = 1:length(first_input)
        % Replicate sub-combinations for each element of the first input
        for j = 1:size(sub_combinations, 1)
            % Set the first column with current element
            output_matrix{row_index, 1} = first_input{i};
            
            % Copy remaining columns from sub-combinations
            output_matrix(row_index, 2:end) = sub_combinations(j, :);
            
            % Increment row index
            row_index = row_index + 1;
        end
    end
end

% Example usage demonstrations
% Simple numeric array
% result1 = f_enumerate_cell_combinations({[1,2], [3,4], [5,6]})

% Mixed types
% result2 = f_enumerate_cell_combinations({[1,2], {'A','B'}, {'X','Y'}})

% Cell arrays
% result3 = f_enumerate_cell_combinations({{'a','b'}, {1,2}, {true,false}})

% Strings
% result4 = f_enumerate_cell_combinations({'Hello', 'World'})