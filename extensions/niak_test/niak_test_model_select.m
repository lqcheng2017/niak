function [pipe] = niak_test_model_select(opt)
% Test the NIAK_MODEL_SELECT command
% PIPE = NIAK_TEST_MODEL_SELECT(OPT)
% OPT.RAND_SEED (scalar or vector, default []) seed of the random number 
%   generate (set using PSOM_SET_RAND_SEED). If left empty, nothing
%   is done.
%
% Copyright (c) Pierre Bellec, Centre de recherche de l'institut de 
% Gériatrie de Montréal, Département d'informatique et de recherche 
% opérationnelle, Université de Montréal, 2014.
% Maintainer : pierre.bellec@criugm.qc.ca
% See licensing information in the code.
% Keywords : test, NIAK, GLM

% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, including without limitation the rights
% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
% copies of the Software, and to permit persons to whom the Software is
% furnished to do so, subject to the following conditions:
%
% The above copyright notice and this permission notice shall be included in
% all copies or substantial portions of the Software.
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
% THE SOFTWARE.

%% Defaults
if (nargin == 0)||~isfield(opt,'rand_seed')
    opt.rand_seed = [];
end

%% Seed the random number generator
if ~isempty(opt.rand_seed)
    psom_set_rand_seed(opt.rand_seed);
end

%% Build a model
model.x = [ones(100,1) randn(100,2) floor(3*rand(100,1))];
b = rand(4,5);
model.y = model.x * b + 0.1*randn(100,5);
model.labels_x = cell(100,1);
for ss = 1:100
    model.labels_x{ss} = sprintf('Subject%i',ss);
end
model.labels_y = { 'intercept' ; 'age' ; 'sex' ; 'patient'};

%% Test 1: simple select
pipe.test1.opt.model = model;
pipe.test1.command = ['fprintf(''Testing selection through age\n'');' ...
                      'opt_test1.select(1).label = ''age'';' ...
                      'opt_test1.select(1).min = 0.5;' ...
                      '[ltest1,itest1] = niak_model_select(opt.model,opt_test1);' ...
                      'if any(itest1 ~= find(opt.model.x(:,2)>0.5));' ...
                      'error(''Test failed'');' ...
                      'end'];

%% Test 2: multiple selects with 'and'
pipe.test2.opt.model = model;
pipe.test2.command = ['fprintf(''Testing selection through age and sex\n'');' ...
                      'opt_test2.select(1).label = ''age'';' ...
                      'opt_test2.select(1).min = 0.5;' ...
                      'opt_test2.select(2).label = ''sex'';' ...
                      'opt_test2.select(2).max = 0.5;' ...
                      'opt_test2.select(2).operation = ''and'';' ...
                      '[ltest2,itest2] = niak_model_select(opt.model,opt_test2);' ...
                      'if any(itest2 ~= find((opt.model.x(:,2)>0.5)&(opt.model.x(:,3)<0.5)));' ...
                      'error(''Test failed'');' ...
                      'end'];

%% Test 3: multiple selects with 'or'
pipe.test3.opt.model = model;
pipe.test3.command = ['fprintf(''Testing selection through age or sex\n'');' ...
                      'opt_test3.select(1).label = ''age'';' ...
                      'opt_test3.select(1).min = 0.5;' ...
                      'opt_test3.select(2).label = ''sex'';' ...
                      'opt_test3.select(2).max = 0.5;' ...
                      'opt_test3.select(2).operation = ''or'';' ...
                      '[ltest3,itest3] = niak_model_select(opt.model,opt_test3);' ...
                      'if any(itest3 ~= find((opt.model.x(:,2)>0.5)|(opt.model.x(:,3)<0.5)));' ...
                      'error(''Test failed'');' ...
                      'end'];

%% Test 4: multiple selects with 'or' and 'and'
pipe.test4.opt.model = model;
pipe.test4.command = ['fprintf(''Testing selection through (age and sex) or clinical status\n'');' ...
                      'opt_test4.select(1).label = ''age'';' ...
                      'opt_test4.select(1).min = 0.5;' ...
                      'opt_test4.select(2).label = ''sex'';' ...
                      'opt_test4.select(2).max = 0.5;' ...
                      'opt_test4.select(2).operation = ''and'';' ...
                      'opt_test4.select(3).label = ''patient'';' ...
                      'opt_test4.select(3).values = [1 2];' ...
                      'opt_test4.select(3).operation = ''or'';' ...                      
                      '[ltest4,itest4] = niak_model_select(opt.model,opt_test4);' ...
                      'if any(itest4 ~= find(((opt.model.x(:,2)>0.5)&(opt.model.x(:,3)<0.5))|(opt.model.x(:,4)>0)));' ...
                      'error(''Test failed'');' ...
                      'end'];

%% Test 5: multiple selects with 'or' and 'and' in the presence of NaNs
pipe.test5.opt.mask_nan = rand(100,1)>0.8;
pipe.test5.opt.model = model;
pipe.test5.opt.model.x(pipe.test5.opt.mask_nan,4) = NaN;
pipe.test5.command = ['fprintf(''Testing selection through (age and sex) or clinical status, in the presence of NaN\n'');' ...
                      'opt_test5.select(1).label = ''age'';' ...
                      'opt_test5.select(1).min = 0.5;' ...
                      'opt_test5.select(2).label = ''sex'';' ...
                      'opt_test5.select(2).max = 0.5;' ...
                      'opt_test5.select(2).operation = ''and'';' ...
                      'opt_test5.select(3).label = ''patient'';' ...
                      'opt_test5.select(3).values = [1 2];' ...
                      'opt_test5.select(3).operation = ''or'';' ...                      
                      '[ltest5,itest5] = niak_model_select(opt.model,opt_test5);' ...
                      'if any(itest5 ~= find(~opt.mask_nan&((opt.model.x(:,2)>0.5)&(opt.model.x(:,3)<0.5))|(opt.model.x(:,4)>0)));' ...
                      'error(''Test failed'');' ...
                      'end'];
                      
%% Test 6: multiple selects in the presence of NaNs which can be ignored
pipe.test6.opt.mask_nan = rand(100,1)>0.8;
pipe.test6.opt.model = model;
pipe.test6.opt.model.x(pipe.test6.opt.mask_nan,4) = NaN;
pipe.test6.command = ['fprintf(''Testing selection through (age and sex), in the presence of NaN in the clinical status which should be ignored\n'');' ...
                      'opt_test6.select(1).label = ''age'';' ...
                      'opt_test6.select(1).min = 0.5;' ...
                      'opt_test6.select(2).label = ''sex'';' ...
                      'opt_test6.select(2).max = 0.5;' ...
                      'opt_test6.select(2).operation = ''and'';' ...
                      'opt_test6.labels_y = { ''age'' , ''sex'' ,''ageXsex''};' ...
                      '[ltest6,itest6] = niak_model_select(opt.model,opt_test6);' ...
                      'if any(itest6 ~= find(((opt.model.x(:,2)>0.5)&(opt.model.x(:,3)<0.5))));' ...
                      'error(''Test failed'');' ...
                      'end'];

%% Test 6: multiple selects in the presence of NaNs which can be ignored, while ignoring some subjects and reordering others
pipe.test7.opt.mask_nan = rand(100,1)>0.8;
pipe.test7.opt.ind_s = randperm(length(model.labels_x));
pipe.test7.opt.ind_s = pipe.test7.opt.ind_s(1:90);
pipe.test7.opt.labels_x = model.labels_x(pipe.test7.opt.ind_s);
pipe.test7.opt.model = model;
pipe.test7.opt.model.x(pipe.test7.opt.mask_nan,4) = NaN;
pipe.test7.command = ['fprintf(''Testing selection through (age and sex), in the presence of NaN in the clinical status which should be ignored, while ignoring some subjects and reordering others\n'');' ...
                      'opt_test7.select(1).label = ''age'';' ...
                      'opt_test7.select(1).min = 0.5;' ...
                      'opt_test7.select(2).label = ''sex'';' ...
                      'opt_test7.select(2).max = 0.5;' ...
                      'opt_test7.select(2).operation = ''and'';' ...
                      'opt_test7.labels_y = { ''age'' , ''sex''};' ...
                      'opt_test7.labels_x = opt.labels_x;';
                      '[ltest7,itest7] = niak_model_select(opt.model,opt_test7);' ...
                      'mask_test = ((opt.model.x(:,2)>0.5)&(opt.model.x(:,3)<0.5)));' ...
                      'mask_test = mask_test(opt.ind_s);' ...
                      'if any(itest7 ~= find(mask_test));' ...
                      'error(''Test failed'');' ...
                      'end'];

%% Test 7: multiple selects in the presence of NaNs which can be ignored, while ignoring some subjects and reordering others as well as adding extra (missing) subjects
pipe.test8.opt.mask_nan = rand(100,1)>0.8;
pipe.test8.opt.ind_s = randperm(length(model.labels_x));
pipe.test8.opt.ind_s = pipe.test8.opt.ind_s(1:90);
pipe.test8.opt.labels_x = [model.labels_x(pipe.test8.opt.ind_s) ; { 'toto' ; 'tata' }];
pipe.test8.opt.model = model;
pipe.test8.opt.model.x(pipe.test8.opt.mask_nan,4) = NaN;
pipe.test8.command = ['fprintf(''Testing selection through (age and sex), in the presence of NaN in the clinical status which should be ignored, while ignoring some subjects and reordering others as well as adding extra (missing) subjects\n'');' ...
                      'opt_test8.select(1).label = ''age'';' ...
                      'opt_test8.select(1).min = 0.5;' ...
                      'opt_test8.select(2).label = ''sex'';' ...
                      'opt_test8.select(2).max = 0.5;' ...
                      'opt_test8.select(2).operation = ''and'';' ...
                      'opt_test8.labels_y = { ''age'' , ''sex''};' ...
                      'opt_test8.labels_x = opt.labels_x;';
                      '[ltest8,itest8] = niak_model_select(opt.model,opt_test8);' ...
                      'mask_test = ((opt.model.x(:,2)>0.5)&(opt.model.x(:,3)<0.5)));' ...
                      'mask_test = mask_test(opt.ind_s);' ...
                      'if any(itest8 ~= find(mask_test));' ...
                      'error(''Test failed'');' ...
                      'end'];
                      