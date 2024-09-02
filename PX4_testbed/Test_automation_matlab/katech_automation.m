clear; clc;close all;

tic;

% Execute the bash script using the system command

set_automation_env = '/home/hmcl/PX4_testbed/automation_codes/set_automation_env.sh';
close_terminal = '/home/hmcl/PX4_testbed/automation_codes/close_terminal.sh';
open_motor_failure_terminal = '/home/hmcl/PX4_testbed/automation_codes/open_motor_failure_terminal.sh';
open_roscore_for_simulink = '/home/hmcl/PX4_testbed/automation_codes/open_roscore_for_simulink.sh';

%시뮬레이션 돌린 날짜
currentDateTime = datetime('now');

% 날짜를 'yyyymmdd' 형식의 문자열로 변환
formattedDate = datestr(currentDateTime, 'yyyymmdd');



%% setup Parameter

% 기준 히트맵과 임계값 설정
% reference 파일의 row와 column 갯수는 내가 뽑고 싶은 히트맵의 row와 column의 갯수가 같아야한다.
% reference 파일의 row size = 내가 뽑고 싶은 히트맵의 row size
% reference 파일의 column size = 내가 뽑고 싶은 히트맵의 column size
load_reference_heatmap = load('heatmap_mat_format_max_xy_error_original_fault_1_0_0_reference.mat'); % reference heatmap 파일을 로드합니다.
reference_heatmap = load_reference_heatmap.heatmap_mat_format_max_xy_error_original; %구조체에서 데이터 추출
threshold_value = 4; % 임계값 설정

% start_date automation돌린 날짜 하지만 원하는 날짜로 바꿔도 된다.
% ex) start_date = 20241225;  원하는 날짜
% ex) start_date = str2double(formattedDate);  현재를 자동입력 날짜
start_date = str2double(formattedDate);

% 이 변수는 폴더이름과 rostopic에 사용된다.
motor_failure_number = 1;
motor_failure_number1 = 6;
motor_failure_number2 = 0;


%gazebo gui를 키면 25초로 설정
%gazebo gui를 끄면 5초로 설정
pause_time_according_to_GUI = 25;

wind_lower = -20;
wind_upper = 20;
increment = 10; % Set increment value (e.g., 0.1, 0.5, 1, etc.)

%{
octocopter figure

5       1
7       3
    ㅁ
6       8
2       4

%}




%% Algorithms start

% 각 모터고장 값을 txt 파일에 저장
fid = fopen('motor_failure_number.txt', 'w');
fprintf(fid, '%d', motor_failure_number);
fclose(fid);

fid = fopen('motor_failure_number1.txt', 'w');
fprintf(fid, '%d', motor_failure_number1);
fclose(fid);

fid = fopen('motor_failure_number2.txt', 'w');
fprintf(fid, '%d', motor_failure_number2);
fclose(fid);


input_wind_x = 0; % don't touch
input_wind_y = 0; % don't touch
input_wind_z = 0; % don't touch

num_x = ceil((wind_upper - wind_lower) / increment) + 1; %only round up
num_y = ceil((wind_upper - wind_lower) / increment) + 1;

i = 0;
cell_format = cell(num_x, num_y);

% Update wind_x and wind_y in the for loop
for wind_x = wind_lower:increment:wind_upper
    for wind_y = wind_lower:increment:wind_upper
        i = i + 1;

        x = round((wind_x - wind_lower) / increment) + 1;
        y = round((wind_y - wind_lower) / increment) + 1;

        mat = [wind_x, wind_y];
        cell_format{x, y} = mat;

        fprintf('mat row = %.1f , column = %.1f\n', x, y);
    end
end

disp('Completed filling cell_format');




heatmap_mat_format_max_roll = zeros(num_x,num_y);
heatmap_mat_format_max_roll_original = zeros(num_x,num_y);

heatmap_mat_format_max_xy_error = zeros(num_x,num_y);
heatmap_mat_format_max_xy_error_original = zeros(num_x,num_y);

heatmap_mat_format_endstep_xy_error = zeros(num_x,num_y);
heatmap_mat_format_endstep_xy_error_original = zeros(num_x,num_y);

heatmap_mat_format_endstep_x_error = zeros(num_x,num_y);
heatmap_mat_format_endstep_x_error_original = zeros(num_x,num_y);

heatmap_mat_format_endstep_y_error = zeros(num_x,num_y);
heatmap_mat_format_endstep_y_error_original = zeros(num_x,num_y);

heatmap_mat_format_endstep_z_error = zeros(num_x,num_y);
heatmap_mat_format_endstep_z_error_original = zeros(num_x,num_y);

heatmap_mat_format_max_x_error = zeros(num_x,num_y);
heatmap_mat_format_max_x_error_original = zeros(num_x,num_y);

heatmap_mat_format_max_y_error = zeros(num_x,num_y);
heatmap_mat_format_max_y_error_original = zeros(num_x,num_y);

heatmap_mat_format_max_z_error = zeros(num_x,num_y);
heatmap_mat_format_max_z_error_original = zeros(num_x,num_y);





open_system("data_collection");
disp('Running the simulink');
pause(10);


for b = 1:num_x
    for a = 1:num_y

        % 기준 히트맵의 값을 확인하고 임계값 초과 시 생략
        if reference_heatmap(a, b) > threshold_value
            fprintf('Threshold exceeded at (%d, %d), skipping simulation.\n', a, b);

            % 히트맵 변수들에 100 설정
            heatmap_mat_format_endstep_x_error(a, b) = 100;
            heatmap_mat_format_endstep_y_error(a, b) = 100;
            heatmap_mat_format_endstep_z_error(a, b) = 100;
            heatmap_mat_format_endstep_xy_error(a, b) = 100;

            heatmap_mat_format_max_x_error(a, b) = 100;
            heatmap_mat_format_max_y_error(a, b) = 100;
            heatmap_mat_format_max_z_error(a, b) = 100;
            heatmap_mat_format_max_xy_error(a, b) = 100;

            % 원본 히트맵 변수들에 100 설정

            heatmap_mat_format_endstep_x_error_original(a, b) = 100;
            heatmap_mat_format_endstep_y_error_original(a, b) = 100;
            heatmap_mat_format_endstep_z_error_original(a, b) = 100;
            heatmap_mat_format_endstep_xy_error_original(a, b) = 100;

            heatmap_mat_format_max_x_error_original(a, b) = 100;
            heatmap_mat_format_max_y_error_original(a, b) = 100;
            heatmap_mat_format_max_z_error_original(a, b) = 100;
            heatmap_mat_format_max_xy_error_original(a, b) = 100;


            heatmap_mat_format_max_roll(a, b) = 100;
            heatmap_mat_format_max_roll_original(a, b) = 100;

            continue;
        end


        system(open_roscore_for_simulink);
        fprintf('-----ROSCORE-------- \n');
        pause(2);
        
        % 모델 이름 정의
        modelName = 'data_collection';

        % 모델 열기
        open_system(modelName);

        % 시뮬레이션 시간 설정 (무한)
        set_param(modelName, 'StopTime', 'inf');

        % 시뮬레이션 시작
        set_param(modelName, 'SimulationCommand', 'start');

        % 다음 명령어 실행
        disp('Simulink starts and the Matlab script continues to run.');



        system(set_automation_env);
        fprintf('set_automation_env.sh is turning on. Please wait. \n');
        pause(10);
        
        system(open_motor_failure_terminal);
        fprintf('motor_failure!!!!!!!!!!! \n');
        pause(10);

        value = cell_format{a,b};
        input_wind_x = value(1);
        input_wind_y = value(2);
    


        set_param('data_collection/wind_x2','Value','input_wind_x');
        set_param('data_collection/wind_y2','Value','input_wind_y');
        fprintf('input_wind_x = %.1f , input_wind_y = %.1f \n', input_wind_x, input_wind_y);

        if abs(input_wind_x) > 15 || abs(input_wind_y) > 15
            % disp('hi');
            pause(10);
        elseif abs(input_wind_x) > 10 || abs(input_wind_y) > 10
            % disp('hello');
            pause(5);
        else
            % disp('lol');
            pause(2.5);
        end





        if evalin('base', 'exist(''max_roll'', ''var'')')
            max_roll = evalin('base', 'max_roll'); % 기본 워크스페이스에서 max_roll 변수를 가져옴
            disp(['max_roll: ', num2str(max_roll)]); % max_roll 의 현재 값을 표시
            if abs(max_roll) > 50   
                heatmap_mat_format_max_roll(a, b) = 100; % max_roll 가 threshold 보다  크면 null 값을 저장
            else
                heatmap_mat_format_max_roll(a, b) = max_roll; % 그렇지 않으면 max_roll 값을 저장
            end
            heatmap_mat_format_max_roll_original(a, b) = max_roll;
        else
            disp('max_roll not yet defined.'); % max_roll 변수가 정의되지 않았음을 표시
            heatmap_mat_format_max_roll(a, b) = 100; % max_roll 변수가 정의되지 않았으면 null 값을 저장
            heatmap_mat_format_max_roll_original(a, b) = 1;
        end



        if evalin('base', 'exist(''max_xy_error'', ''var'')')
            max_xy_error = evalin('base', 'max_xy_error'); % 기본 워크스페이스에서 max_xy_error 변수를 가져옴
            disp(['Current max_xy_error: ', num2str(max_xy_error)]); % max_xy_error 의 현재 값을 표시
            if abs(max_xy_error) > 20
                heatmap_mat_format_max_xy_error(a, b) = 100; % max_xy_error 가 threshold 보다  크면 null 값을 저장
            else
                heatmap_mat_format_max_xy_error(a, b) = max_xy_error; % 그렇지 않으면 max_xy_error 값을 저장
            end
            heatmap_mat_format_max_xy_error_original(a, b) = max_xy_error;
        else
            disp('max_xy_error not yet defined.'); % max_xy_error 변수가 정의되지 않았음을 표시
            heatmap_mat_format_max_xy_error(a, b) = 100; % max_xy_error 변수가 정의되지 않았으면 null 값을 저장
            heatmap_mat_format_max_xy_error_original(a, b) = 1;
        end

        
        if evalin('base', 'exist(''endstep_xy_error'', ''var'')')
            endstep_xy_error = evalin('base', 'endstep_xy_error'); % 기본 워크스페이스에서 endstep_xy_error 변수를 가져옴
            disp(['Current endstep_xy_error: ', num2str(endstep_xy_error)]); % endstep_xy_error 의 현재 값을 표시
            if abs(endstep_xy_error) > 20
                heatmap_mat_format_endstep_xy_error(a, b) = 100; % endstep_xy_error 가 threshold 보다  크면 null 값을 저장
            else
                heatmap_mat_format_endstep_xy_error(a, b) = endstep_xy_error; % 그렇지 않으면 endstep_xy_error 값을 저장
            end
            heatmap_mat_format_endstep_xy_error_original(a, b) = endstep_xy_error;
        else
            disp('endstep_xy_error not yet defined.'); % endstep_xy_error 변수가 정의되지 않았음을 표시
            heatmap_mat_format_endstep_xy_error(a, b) = 100; % endstep_xy_error 변수가 정의되지 않았으면 null 값을 저장
            heatmap_mat_format_endstep_xy_error_original(a, b) = 1;
        end




        if evalin('base', 'exist(''endstep_x_error'', ''var'')')
            endstep_x_error = evalin('base', 'endstep_x_error'); % 기본 워크스페이스에서 endstep_x_error 변수를 가져옴
            disp(['Current endstep_x_error: ', num2str(endstep_x_error)]); % endstep_x_error 의 현재 값을 표시
            if abs(endstep_x_error) > 20
                heatmap_mat_format_endstep_x_error(a, b) = 100; % endstep_x_error 가 threshold 보다  크면 null 값을 저장
            else
                heatmap_mat_format_endstep_x_error(a, b) = endstep_x_error; % 그렇지 않으면 endstep_x_error 값을 저장
            end
            heatmap_mat_format_endstep_x_error_original(a, b) = endstep_x_error;
        else
            disp('endstep_x_error not yet defined.'); % endstep_x_error 변수가 정의되지 않았음을 표시
            heatmap_mat_format_endstep_x_error(a, b) = 100; % endstep_x_error 변수가 정의되지 않았으면 null 값을 저장
            heatmap_mat_format_endstep_x_error_original(a, b) = 1;
        end





        if evalin('base', 'exist(''endstep_y_error'', ''var'')')
            endstep_y_error = evalin('base', 'endstep_y_error'); % 기본 워크스페이스에서 endstep_y_error 변수를 가져옴
            disp(['Current endstep_y_error: ', num2str(endstep_y_error)]); % endstep_y_error 의 현재 값을 표시
            if abs(endstep_y_error) > 20
                heatmap_mat_format_endstep_y_error(a, b) = 100; % endstep_y_error 가 threshold 보다  크면 null 값을 저장
            else
                heatmap_mat_format_endstep_y_error(a, b) = endstep_y_error; % 그렇지 않으면 endstep_y_error 값을 저장
            end
            heatmap_mat_format_endstep_y_error_original(a, b) = endstep_y_error;
        else
            disp('endstep_y_error not yet defined.'); % endstep_y_error 변수가 정의되지 않았음을 표시
            heatmap_mat_format_endstep_y_error(a, b) = 100; % endstep_y_error 변수가 정의되지 않았으면 null 값을 저장
            heatmap_mat_format_endstep_y_error_original(a, b) = 1;
        end


        if evalin('base', 'exist(''endstep_z_error'', ''var'')')
            endstep_z_error = evalin('base', 'endstep_z_error'); % 기본 워크스페이스에서 endstep_z_error 변수를 가져옴
            disp(['Current endstep_z_error: ', num2str(endstep_z_error)]); % endstep_z_error 의 현재 값을 표시
            if abs(endstep_z_error) > 20
                heatmap_mat_format_endstep_z_error(a, b) = 100; % endstep_z_error 가 threshold 보다  크면 null 값을 저장
            else
                heatmap_mat_format_endstep_z_error(a, b) = endstep_z_error; % 그렇지 않으면 endstep_z_error 값을 저장
            end
            heatmap_mat_format_endstep_z_error_original(a, b) = endstep_z_error;
        else
            disp('endstep_z_error not yet defined.'); % endstep_z_error 변수가 정의되지 않았음을 표시
            heatmap_mat_format_endstep_z_error(a, b) = 100; % endstep_z_error 변수가 정의되지 않았으면 null 값을 저장
            heatmap_mat_format_endstep_z_error_original(a, b) = 1;
        end


        if evalin('base', 'exist(''max_x_error'', ''var'')')
            max_x_error = evalin('base', 'max_x_error'); % 기본 워크스페이스에서 max_x_error 변수를 가져옴
            disp(['Current max_x_error: ', num2str(max_x_error)]); % max_x_error 의 현재 값을 표시
            if abs(max_x_error) > 20
                heatmap_mat_format_max_x_error(a, b) = 100; % max_x_error 가 threshold 보다  크면 null 값을 저장
            else
                heatmap_mat_format_max_x_error(a, b) = max_x_error; % 그렇지 않으면 max_x_error 값을 저장
            end
            heatmap_mat_format_max_x_error_original(a, b) = max_x_error;
        else
            disp('max_x_error not yet defined.'); % max_x_error 변수가 정의되지 않았음을 표시
            heatmap_mat_format_max_x_error(a, b) = 100; % max_x_error 변수가 정의되지 않았으면 null 값을 저장
            heatmap_mat_format_max_x_error_original(a, b) = 1;
        end


        if evalin('base', 'exist(''max_y_error'', ''var'')')
            max_y_error = evalin('base', 'max_y_error'); % 기본 워크스페이스에서 max_y_error 변수를 가져옴
            disp(['Current max_y_error: ', num2str(max_y_error)]); % max_y_error 의 현재 값을 표시
            if abs(max_y_error) > 20
                heatmap_mat_format_max_y_error(a, b) = 100; % max_y_error 가 threshold 보다  크면 null 값을 저장
            else
                heatmap_mat_format_max_y_error(a, b) = max_y_error; % 그렇지 않으면 max_y_error 값을 저장
            end
            heatmap_mat_format_max_y_error_original(a, b) = max_y_error;
        else
            disp('max_y_error not yet defined.'); % max_y_error 변수가 정의되지 않았음을 표시
            heatmap_mat_format_max_y_error(a, b) = 100; % max_y_error 변수가 정의되지 않았으면 null 값을 저장
            heatmap_mat_format_max_y_error_original(a, b) = 1;
        end


        if evalin('base', 'exist(''max_z_error'', ''var'')')
            max_z_error = evalin('base', 'max_z_error'); % 기본 워크스페이스에서 max_z_error 변수를 가져옴
            disp(['Current max_z_error: ', num2str(max_z_error)]); % max_z_error 의 현재 값을 표시
            if abs(max_z_error) > 20
                heatmap_mat_format_max_z_error(a, b) = 100; % max_z_error 가 threshold 보다  크면 null 값을 저장
            else
                heatmap_mat_format_max_z_error(a, b) = max_z_error; % 그렇지 않으면 max_z_error 값을 저장
            end
            heatmap_mat_format_max_z_error_original(a, b) = max_z_error;
        else
            disp('max_z_error not yet defined.'); % max_z_error 변수가 정의되지 않았음을 표시
            heatmap_mat_format_max_z_error(a, b) = 100; % max_z_error 변수가 정의되지 않았으면 null 값을 저장
            heatmap_mat_format_max_z_error_original(a, b) = 1;
        end




        set_param('data_collection/wind_x2','Value','0');
        set_param('data_collection/wind_y2','Value','0');
        fprintf('input_wind_x = %.1f , input_wind_y = %.1f measured wind  \n', input_wind_x, input_wind_y);

        % Now you can kill the terminals using their PIDs
        system(close_terminal);

        % 시뮬레이션 멈춤
        set_param(modelName, 'SimulationCommand', 'stop');
        
        fprintf('---------Terminals and simulink closed---------------- \n\n');
        pause(pause_time_according_to_GUI);





    end
end


%% Save data after algorithm ends

% 폴더 이름 생성
save_folder = sprintf('%dby%d_increment_%d_fault_%d_%d_%d_date_%d', wind_upper * 2, wind_upper * 2, increment, motor_failure_number, motor_failure_number1,motor_failure_number2,start_date);

% 폴더가 존재하지 않으면 생성
if ~exist(save_folder, 'dir')
    mkdir(save_folder);
end

% 파일 이름 생성
filename = sprintf('%s/%dby%d_increment_%d_fault_%d_%d_%d_date_%d.mat', save_folder, wind_upper * 2, wind_upper * 2, increment, motor_failure_number, motor_failure_number1,motor_failure_number2,start_date);

% 히트맵 제목
titlename = sprintf('xy maximum error for No. %d, %d, %d fault', motor_failure_number, motor_failure_number1,motor_failure_number2);
titlename1 = sprintf('roll maximum error for No. %d, %d, %d fault', motor_failure_number, motor_failure_number1,motor_failure_number2);
titlename2 = sprintf('xy max error at Last Time Step for No. %d, %d, %d fault', motor_failure_number, motor_failure_number1,motor_failure_number2);

% 변수들을 저장 (MAT 파일 형식 7.3 지정)
save(filename, '-v7.3');



%% Heatmap with value display

figure();
hh = heatmap(wind_lower:increment:wind_upper, wind_lower:increment:wind_upper,heatmap_mat_format_max_xy_error_original);
hh.Title = strcat(titlename, ' original');
hh.XLabel = 'Wind Y';
hh.YLabel = 'Wind X';
hh.Colormap = jet;
hh.ColorLimits = [0 5];
hh.CellLabelColor = 'none';
hh.GridVisible = 'off';

figure();
jj = heatmap(wind_lower:increment:wind_upper, wind_lower:increment:wind_upper,heatmap_mat_format_max_xy_error);
jj.Title = titlename;
jj.XLabel = 'Wind Y';
jj.YLabel = 'Wind X';
jj.Colormap = jet;
jj.ColorLimits = [0 5];
jj.CellLabelColor = 'none';
jj.GridVisible = 'off';

figure();
kk = heatmap(wind_lower:increment:wind_upper, wind_lower:increment:wind_upper,heatmap_mat_format_max_roll_original);
kk.Title = strcat(titlename1, ' original');
kk.XLabel = 'Wind Y';
kk.YLabel = 'Wind X';
kk.Colormap = jet;
kk.ColorLimits = [0 30];
kk.CellLabelColor = 'none';
kk.GridVisible = 'off';

figure();
ll = heatmap(wind_lower:increment:wind_upper, wind_lower:increment:wind_upper,heatmap_mat_format_max_roll);
ll.Title = titlename1;
ll.XLabel = 'Wind Y';
ll.YLabel = 'Wind X';
ll.Colormap = jet;
ll.ColorLimits = [0 30];
ll.CellLabelColor = 'none';
ll.GridVisible = 'off';


figure();
asas = heatmap(wind_lower:increment:wind_upper, wind_lower:increment:wind_upper,heatmap_mat_format_endstep_xy_error_original);
asas.Title = strcat(titlename2, ' original');
asas.XLabel = 'Wind Y';
asas.YLabel = 'Wind X';
asas.Colormap = jet;
asas.ColorLimits = [0 5];
asas.CellLabelColor = 'none';
asas.GridVisible = 'off';

figure();
bsbs = heatmap(wind_lower:increment:wind_upper, wind_lower:increment:wind_upper,heatmap_mat_format_endstep_xy_error);
bsbs.Title = titlename2;
bsbs.XLabel = 'Wind Y';
bsbs.YLabel = 'Wind X';
bsbs.Colormap = jet;
bsbs.ColorLimits = [0 5];
bsbs.CellLabelColor = 'none';
bsbs.GridVisible = 'off';




toc;
