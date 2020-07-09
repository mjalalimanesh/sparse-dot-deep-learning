function [nhomo_experiment_3, nexperiment_3_1, nexperiment_3_2, nexperiment_3_3, nexperiment_3_4, nexperiment_3_5, nexperiment_3_6, nexperiment_3_7] = read_experiment_data()

dark_correction = [1.575, 3.85, 1, 0.85, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 , 0,  ...
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0.85, 1, 3.85, 1.575];

homo_experiment_3 = [60.8, 40.8, 28.6, 20.6, 16, 12.8, 10.6, 9.3, 8.4, 8.1, 8.3, 8.7, 8.6, 8.3, 8.3, ...
    8.4, 8.8, 8.7, 8, 8, 8, 8.8, 10.1, 12.2, 15.2, 20.2, 27.6, 40.8, 60.8];
homo_experiment_3 = homo_experiment_3 - dark_correction;

experiment_3_2 = [58.6, 40, 27.6, 19.8, 15, 11.8, 9.4, 8, 6.8, 6.3, 6, 5.9, 5.2, 4.7, 4.5,  ...
    4.9, 5.6, 5.9, 5.7, 6, 6.4, 7.4, 8.8, 11.3, 14.2, 18.8, 26.4, 38.4, 57.6];
experiment_3_2 = experiment_3_2 - dark_correction;

experiment_3_1 = [59.8, 40.8, 27.2, 20.2, 15, 12, 10, 8.6, 7.7, 7.4, 7.4, 7.6, 7.4, 7.1, 6.8, ...
    6.7, 6.8, 6.2, 5.3, 4.5, 4, 3.8, 3.9, 4.8, 6.6, 10.8, 18.8, 32.4, 53.6];
experiment_3_1 = experiment_3_1 - dark_correction;

experiment_3_3 = [57.6, 38, 26.4, 19.2, 14.8, 11.6, 9.7, 8.3, 7.5, 7.4, 7.4, 7.6, 7.4, 7.2, 6.9,  ...
    7, 7.2, 6.6, 5.8, 5.2, 5.1, 5.2, 5.8, 7.4, 9.8, 14.4, 21.6, 36, 55.2];
experiment_3_3 = experiment_3_3 - dark_correction;

experiment_3_4 = [57.6, 38.4, 26.8, 19.2, 14.8, 11.6, 9.2, 7.8, 6.8, 6.2, 6, 6, 5.7, 5.2, 5.2,  ...
    5.6, 6.1, 6.2, 6, 6, 6.6, 7.4, 8.9, 11.3, 14.4, 19.6, 27.2, 39.2, 58.4 ];
experiment_3_4 = experiment_3_4 - dark_correction;

experiment_3_5 = [54.4, 32, 19.8, 12.8, 8.8, 7.2, 6.4, 6, 5.6, 6, 6.4, 7, 7.1, 7.1, 7.1,  ...
    7.4, 7.6, 7.4, 7.1, 7, 7.2, 8, 9.1, 11.1, 14.4, 18.8, 26.2, 38.8, 58];
experiment_3_5 = experiment_3_5 - dark_correction;

experiment_3_6 = [58.4, 38, 27, 20, 14.7, 11.6, 9.4, 8, 6.9, 6.6, 6.5, 6.6, 6.4, 6, 6, ...
    6.2, 6.6, 6.6, 6.1, 6.2, 6.6, 7.4, 8.8, 11, 14, 18.8, 26, 37.6, 57.6];
experiment_3_6 = experiment_3_6 - dark_correction;

experiment_3_7 = [50.4, 32, 20.8, 14.4, 10.4, 8, 6.6, 5.8, 5.2, 5.4, 5.8, 6.3, 6.3, 6.1, 6.1, ...
    6.3, 6.6, 6.3, 5.7, 5.4, 5.5, 6, 6.9, 8.7, 11.3, 15.6, 22.6, 35.2, 52];
experiment_3_7 = experiment_3_7 - dark_correction;


nhomo_experiment_3 = homo_experiment_3/max(max(homo_experiment_3));
nexperiment_3_7 = experiment_3_7/max(max(experiment_3_7));
nexperiment_3_6 = experiment_3_6/max(max(experiment_3_6));
nexperiment_3_5 = experiment_3_5/max(max(experiment_3_5));
nexperiment_3_4 = experiment_3_4/max(max(experiment_3_4));
nexperiment_3_3 = experiment_3_3/max(max(experiment_3_3));
nexperiment_3_2 = experiment_3_2/max(max(experiment_3_2));
nexperiment_3_1 = experiment_3_1/max(max(experiment_3_1));

end