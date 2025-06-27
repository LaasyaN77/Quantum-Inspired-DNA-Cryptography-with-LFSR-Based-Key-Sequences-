function lfsr_gui_app()
    % Create UI figure
fig = uifigure('Name', 'LFSR DNA Encryption - Decryption', ...
    'Position', [100 100 800 800], ...
    'Color', [0.9, 0.9, 0.98]);

% Title
uilabel(fig, 'Text', 'Encrypt, Decrypt & Test 🗝', ...
    'FontSize', 20, 'FontWeight', 'bold', ...
    'Position', [250 740 400 30]);

% Seed input
uilabel(fig, 'Text', 'Seed:', 'Position', [50 690 50 22]);
seedField = uieditfield(fig, 'text', ...
    'Position', [100 690 200 22]);

% Polynomial input
uilabel(fig, 'Text', 'Polynomial:', 'Position', [320 690 70 22]);
polField = uieditfield(fig, 'text', ...
    'Position', [400 690 200 22]);

% Count input
uilabel(fig, 'Text', 'Count:', 'Position', [620 690 50 22]);
countField = uieditfield(fig, 'numeric', ...
    'Position', [670 690 60 22]);

% Run button
runBtn = uibutton(fig, 'Text', 'Run Pipeline', ...
    'Position', [340 620 120 30], 'Tooltip', 'Runs the LFSR encryption-decryption sequence', ...
    'ButtonPushedFcn', @(btn,event) runPipeline(seedField.Value, polField.Value, countField.Value, fig));

% Log 
uilabel(fig, 'Text', 'Log:', 'Position', [50 580 100 22]);
logBox = uitextarea(fig, ...
    'Position', [50 390 700 190], ...
    'Editable', 'off','BackgroundColor',[0.975 1.00 0.975]);

% DNA Sequence 
uilabel(fig, 'Text', '🧬 DNA Sequence:', 'Position', [50 340 120 22]);
dnaOut = uitextarea(fig, ...
    'Position', [50 310 700 30], ...
    'Editable', 'off','BackgroundColor', [0.95 0.98 1.00]);

% Encrypted DNA 
uilabel(fig, 'Text', '🔒 Encrypted DNA:', 'Position', [50 270 120 22]);
encOut = uitextarea(fig, ...
    'Position', [50 240 700 30], ...
    'Editable', 'off','BackgroundColor', [0.95 0.98 1.00]);

% Decrypted DNA 
uilabel(fig, 'Text', '🔓 Decrypted DNA:', 'Position', [50 200 120 22]);  
decOut = uitextarea(fig, ...
    'Position', [50 170 700 30], ...  
    'Editable', 'off','BackgroundColor', [0.95 0.98 1.00]);

% Test Button
testBtn = uibutton(fig, 'Text', 'Test It', ...
    'Position', [340 120 120 30], 'Tooltip', 'Run entropy and avalanche effect analysis', ...
    'ButtonPushedFcn', @(btn,event) runTesting(fig));


% Results Text Area
testOut = uitextarea(fig, ...
    'Position', [50 40 700 60], ...
    'Editable', 'off','BackgroundColor', [0.975 1.00 0.975]);

% Footer Credit
    uilabel(fig, 'Text', 'Developed by Bhaavya P, Laasya N, Akhila C, Divyanshi E ', ...
        'Position', [200 10 400 20], 'HorizontalAlignment', 'center', ...
        'FontSize', 10, 'FontAngle', 'italic', 'FontColor', [0.4 0.4 0.4]);

    % Save UI handles
handles = struct('dnaOut', dnaOut, 'encOut', encOut, 'decOut', decOut, ...
                 'logBox', logBox, 'testOut', testOut, ...
                 'seedField', seedField, 'polField', polField, 'countField', countField);

    fig.UserData = handles;
end

function runPipeline(seedStr, polStr, count, fig)
    handles = fig.UserData;

    seed = seedStr;
    pol = str2num(polStr); %#ok<ST2NM>

    [final_dna_seq, final_encrypted_dna, final_decrypted_dna, ~, logstr] = lfsr_pipeline(seed, pol, count);

    % Just update log with iteration details only
    handles.logBox.Value = cellstr(splitlines(logstr));

    % Update DNA, encrypted, decrypted outputs
    handles.dnaOut.Value = final_dna_seq;
    handles.encOut.Value = final_encrypted_dna;
    handles.decOut.Value = final_decrypted_dna;

    save('crypto_data.mat', 'final_dna_seq', 'final_encrypted_dna', 'final_decrypted_dna', 'seed', 'pol', 'count');
end

function runTesting(fig)
    handles = fig.UserData;

    seed = handles.seedField.Value;
    pol = str2num(handles.polField.Value); %#ok<ST2NM>
    count = handles.countField.Value;

    entropies = zeros(1,count);
    avalanche_vals = zeros(1,count);

    for i = 1:count
       
        entropy_val = calculate_entropy(strjoin(handles.encOut.Value, ''));
        avalanche_percent = test_avalanche(seed, pol, count);

        entropies(i) = entropy_val;
        avalanche_vals(i) = avalanche_percent;
    end

    avg_entropy = mean(entropies);
    avg_avalanche = mean(avalanche_vals);

    results = sprintf('Average Entropy of encrypted DNA: %.4f\nAverage Avalanche Effect: %.2f%%', avg_entropy, avg_avalanche);
    handles.testOut.Value = results;
end




function [final_dna_seq, final_encrypted_dna, final_decrypted_dna, key_seq, logstr] = lfsr_pipeline(seed, pol, count)
    seed = seed - '0';  % Convert string to numeric array
    reg_len = length(seed);

    % Check if seed length is even
    if mod(reg_len, 2) ~= 0
        error('Seed length must be even to allow DNA encoding.');
    end

    logstr = "";
    key_seq = [];
    
    for i = 1:count
        % Compute XOR bit using tap positions
        xor_bit = 0;
        for j = 1:length(pol)
            if pol(j) == 1
                xor_bit = bitxor(xor_bit, seed(j));
            end
        end

        % Update LFSR register (shift and insert xor_bit)
        seed = [xor_bit, seed(1:end-1)];

        % Current bit sequence to consider for DNA & encryption
        current_bits = seed;

        % DNA encode
        dna_seq = dna_encoding(current_bits);

        % Quantum encrypt
        [encrypted_dna, key_choices] = quantum_entanglement_xor_encrypt(dna_seq);

        % Quantum decrypt
        decrypted_dna = quantum_entanglement_xor_decrypt(encrypted_dna, key_choices);

        % Check match
        match_str = "❌ Mismatch";
        if strcmp(dna_seq, decrypted_dna)
            match_str = "✅ Match";
        end

        % Build log entry for this iteration
        logstr = logstr + sprintf("Iteration %d:\n", i);
        logstr = logstr + sprintf("LFSR Bits: %s\n", num2str(current_bits));
        logstr = logstr + sprintf("DNA Encoded: %s\n", dna_seq);
        logstr = logstr + sprintf("Quantum Encrypted: %s\n", encrypted_dna);
        logstr = logstr + sprintf("Quantum Decrypted: %s\n", decrypted_dna);
        logstr = logstr + sprintf("Decryption Status: %s\n\n", match_str);
    end

    % Final output (from last iteration)
    final_dna_seq = dna_seq;
    final_encrypted_dna = encrypted_dna;
    final_decrypted_dna = decrypted_dna;
    key_seq = key_choices;
end


function [dna_seq, logstr] = dna_encoding(seq)
    mapping = containers.Map({'00','01','10','11'}, {'A','T','G','C'});
    dna_seq = '';
    logstr = "";
    for k = 1:2:length(seq)-1
        pair = seq(k:k+1);
        key = sprintf('%d%d', pair(1), pair(2));
        dna_seq = strcat(dna_seq, mapping(key));
    end
    logstr = sprintf('DNA Encoded: %s\n', dna_seq);
end

function [enc_dna, key_seq, logstr] = quantum_entanglement_xor_encrypt(dna_seq)
    base_to_bin = containers.Map({'A','T','G','C'}, {[0 0],[0 1],[1 0],[1 1]});
    bin_to_base = containers.Map({0,1,2,3}, {'A','T','G','C'});
    trans_map = containers.Map(...
        {'A','T','G','C'}, ...
        {{'AT','CG','TA','GC'}, {'TC','AG','CT','GA'}, {'GT','CA','TG','AC'}, {'CG','TA','GC','AT'}});
    
    enc_dna = '';
    key_seq = [];
    prev_bin = [0 0];
    logstr = "";
    for i = 1:length(dna_seq)
        base = dna_seq(i);
        curr_bin = base_to_bin(base);
        xor_bin = bitxor(curr_bin, prev_bin);
        xor_val = xor_bin(1)*2 + xor_bin(2);
        entangled_base = bin_to_base(xor_val);
        choices = trans_map(entangled_base);
        key_choice = randi([1 4]);
        enc_pair = choices{key_choice};
        enc_dna = strcat(enc_dna, enc_pair);
        key_seq = [key_seq, key_choice];
        prev_bin = curr_bin;
    end
    logstr = sprintf('Encrypted DNA: %s\n', enc_dna);
end

function [decrypted_dna, logstr] = quantum_entanglement_xor_decrypt(enc_dna, key_seq)
    base_to_bin = containers.Map({'A','T','G','C'}, {[0 0],[0 1],[1 0],[1 1]});
    bin_to_base = containers.Map({0,1,2,3}, {'A','T','G','C'});
    trans_map = containers.Map(...
        {'A','T','G','C'}, ...
        {{'AT','CG','TA','GC'}, {'TC','AG','CT','GA'}, {'GT','CA','TG','AC'}, {'CG','TA','GC','AT'}});
    
    original_dna = '';
    prev_bin = [0 0];
    logstr = "";
    for i = 1:2:length(enc_dna)
        enc_pair = enc_dna(i:i+1);
        key_choice = key_seq((i+1)/2);
        found = false;
        bases = {'A','T','G','C'};
        for b = 1:4
            base = bases{b};
            choices = trans_map(base);
            if strcmp(choices{key_choice}, enc_pair)
                entangled_base = base;
                found = true;
                break;
            end
        end
        if ~found
            error('Decryption error at pair %s', enc_pair);
        end
        entangled_bin = base_to_bin(entangled_base);
        orig_bin = bitxor(entangled_bin, prev_bin);
        orig_val = orig_bin(1)*2 + orig_bin(2);
        orig_base = bin_to_base(orig_val);
        original_dna = strcat(original_dna, orig_base);
        prev_bin = base_to_bin(orig_base);
    end
    logstr = sprintf('Decrypted DNA: %s\n', original_dna);
    decrypted_dna = original_dna;
end

function entropy_val = calculate_entropy(seq)
    bases = ['A', 'T', 'G', 'C'];
    n = length(seq);
    entropy_val = 0;
    for i = 1:length(bases)
        p = sum(seq == bases(i)) / n;
        if p > 0
            entropy_val = entropy_val - p * log2(p);
        end
    end
end

function percent = test_avalanche(seed, pol, count)
    [~, enc1, ~, ~] = lfsr_pipeline(seed, pol, count);
    flipped_seed = seed;
    flipped_seed(1) = num2str(1 - str2double(seed(1)));
    [~, enc2, ~, ~] = lfsr_pipeline(flipped_seed, pol, count);

    min_len = min(length(enc1), length(enc2));
    enc1 = enc1(1:min_len);
    enc2 = enc2(1:min_len);
    diff_bits = sum(enc1 ~= enc2);
    percent = (diff_bits / min_len)*100;
end
