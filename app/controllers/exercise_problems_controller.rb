class ExerciseProblemsController < ApplicationController
  before_filter :req_psetter, :except => [:show, :download]

    def show
      @exercise_problem = ExerciseProblem.find(params[:id])
      @problem = @exercise_problem.problem
      ex = @exercise_problem.exercise
      v1 = @current_user.valid_exercise? ex
      v2 = ex.current?
      if !(v1 && v2)
        redirect_to :root, :notice => "You can't see this contest"
      end
    end

    def create
        @exercise = Exercise.find(params[:exercise_id])
        @exercise_problem = @exercise.exercise_problems.create(params[:exercise_problem])
        redirect_to exercise_path(@exercise)
    end

    def destroy
        @exercise = Exercise.find(params[:exercise_id])
        @exercise_problem = @exercise.exercise_problems.find(params[:id])
        @exercise_problem.destroy
        redirect_to exercise_path(@exercise)
    end

    def rejudge
        ep = ExerciseProblem.find(params[:id])
        ep.rejudge
        flash[:class] = "alert alert-success"
        redirect_to exercise_path(ep.exercise), :notice => "Rejudging the problem for this contest"
    end

    def download
      @exercise_problem = ExerciseProblem.find(params[:id])
      @problem = @exercise_problem.problem
      ex = @exercise_problem.exercise
      v1 = @current_user.valid_exercise? ex
      v2 = ex.current?
      if !(v1 && v2)
        redirect_to :root, :notice => "You can't see this contest"
      else
        send_file "#{@exercise_problem.problem.pdescription.path}" , :type=>"application/pdf"
      end
    end
end
