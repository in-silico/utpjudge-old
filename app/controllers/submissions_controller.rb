class SubmissionsController < ApplicationController
  before_filter :req_psetter, :only=>[:destroy,:update,:edit]
  before_filter :req_gen_user, :except=>[:destroy,:update,:edit,:judgebot,:bot_testcase,:update_veredict,:pending]
  http_basic_authenticate_with :name => "user", :password => "password", :only => [:judgebot,:bot_testcase,:update_veredict,:pending]

  # GET /submissions
  # GET /submissions.json
  def index
    u_id = params[:uid]
    if (!u_id || Integer(u_id)!=@current_user.id)
      authorized = @current_user.has_roles(User.roles[:psetter])
      redirect_to :root and return if not authorized
    end
    if u_id
      @submissions = User.find(u_id).submissions.paginate(:page => params[:page], :per_page => 5).order('created_at DESC')
    else
      @submissions = Submission.paginate(:page => params[:page], :per_page => 5).order('created_at DESC')
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @submissions }
    end
  end


  # GET /submissions/1
  # GET /submissions/1.json
  def show
    @submission = Submission.find(params[:id])
    is_authorized = @current_user.id == @submission.user.id || @current_user.has_roles(User.roles[:psetter])
    redirect_to :root and return if not is_authorized

    #if (@submission.veredict == "Judging" || @submission.veredict.length == 0)
      #@submission.judge
    #end
    @exercise_problem = @submission.exercise_problem
    @srccode = @submission.source

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @submission }
      format.xml { render xml: @submission }
    end
  end

  #GET /submissions/1/judgebot.json (Called by judge)
  # Download the submission identified by the given ID (params[:id])
  def judgebot
      @submission = Submission.find(params[:id])
      @srccode = @submission.source
      @lang = @submission.language
      fname = @submission.exercise_problem.problem.checker.path

      if( fname == nil )
          fname = "protected/checkers/checker.cpp"
      end

      tmp = File.open(fname,'r')
      @checker = tmp.read
      @chlang  = fname.split('.')[-1]

      respond_to do |format|
          format.json { render json: [@submission,@srccode,@lang,@submission.exercise_problem, @checker, @chlang] }
      end
  end

  #GET /submissions/1/bot_testcase.json (Called by judge)
  # Used to download testcases by the judgebot
  def bot_testcase
      @submission = Submission.find(params[:id])

      respond_to do |format|
          format.json { render json: @submission.get_test_cases }
      end
  end

  #GET /submissions/pending.json
  def pending
      @pend_ids = Submission.where(:veredict => 'Judging').pluck(:id)
      respond_to do |format|
          format.json { render json: @pend_ids }
      end
  end

  #POST receive the veredict from judbot
  def update_veredict
    @submission = Submission.find(params[:id])
    time = params[:time]
    sub_id    = params[:id]
    veredict  = params[:veredict]

    @submission.veredict = veredict
    @submission.time = time

    respond_to do |format|
      format.json { render json: [veredict] }
    end

    #update on DB
    @submission.update_attributes(params[:submission])

  end

  # GET /submissions/new
  def new
      @exercise_problem = ExerciseProblem.find(params[:exercise_problem])
      @jtype = Testcase.judgeTypeHash[@exercise_problem.stype]
#     flash.now[:notice] = @jtype

      if @jtype==:downloadInput
        @submission = Submission.newJudgeDownload(@exercise_problem)
        @submission.user = current_user
        @submission.save
        render "jdownload"
      else
        @language = Language.all
        @submission = Submission.newJudgeSource(@exercise_problem)
#        @submission.user = current_user
#        @submission.save
        render "jupload"
      end

  end

  def jdownload
     @submission = Submission.find(params[:id])
     @submission.end_date = Time.now.to_s(:db)

     if @submission.user.valid_exercise? @submission.exercise_problem.exercise
        respond_to do |format|
          if @submission.update_attributes(params[:submission]) && @submission.judge
            #if success redirect to show action
            flash[:class] = "alert alert-success"
            format.html { redirect_to @submission, notice: 'Your submission was successfully sent.' }
            format.json { head :no_content }
          else
            format.html { render action: "new" }
            format.json { render json: @submission.errors, status: :unprocessable_entity }
          end
        end
      else
        redirect_to :root, :notice => "You can't do this submission because this exercise is not avaible for you"
      end
  end

  def jupload
    @exercise_problem = ExerciseProblem.find(params[:exercise_problem_id])
    @submission = Submission.newJudgeSource(@exercise_problem)
    @submission.language = Language.find(params[:language_id])
    @submission.end_date = Time.now.to_s(:db)
    @submission.user = current_user
    @submission.save

    if( params[:srcfile] == nil )
      srcpaste = params[:srcpaste];
      if( srcpaste.length > 0 )
        fname = "/tmp/#{@submission.exercise_problem.problem.name[0]}.#{@submission.language.extension}"
        f = File.open(fname,'w')
        f.write(srcpaste)
        f.close
        @submission.srcfile = File.open(fname,'r')
        @submission.save
      end
    end

    respond_to do |format|
      if @submission.update_attributes(params[:submission]) && @submission.judge
        #if success redirect to show action
        flash[:class] = "alert alert-success"
        format.html { redirect_to @submission, notice: 'Your submission was successfully sent.' }
        format.json { head :no_content }
      else
        format.html { render action: "new" }
        format.json { render json: @submission.errors, status: :unprocessable_entity }
      end
    end
  end

  #GET /submissions/downloadInput?exercise_problem=id
  def downloadInput
      @exercise_problem = ExerciseProblem.find(params[:exercise_problem])
      problem = @exercise_problem.problem
      testcase = problem.testcases.where(:jtype => @exercise_problem.stype).first
      send_file testcase.infile.path, :type=>"application/text"
  end

  # GET /submissions/1/edit
  def edit
    @submission = Submission.find(params[:id])
  end

  # POST /submissions
  # POST /submissions.json
  def create
    @submission = Submission.new(params[:submission])

    respond_to do |format|
      if @submission.save
        format.html { redirect_to @submission, notice: 'Submission was successfully created.' }
        format.json { render json: @submission, status: :created, location: @submission }
      else
        format.html { render action: "new" }
        format.json { render json: @submission.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /submissions/1
  # PUT /submissions/1.json
  def update
    @submission = Submission.find(params[:id])

    @submission.veredict = params[:veredict]
    respond_to do |format|
      if @submission.update_attributes(params[:submission])
        format.html { redirect_to @submission, notice: 'Submission was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @submission.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /submissions/1
  # DELETE /submissions/1.json
  def destroy
    @submission = Submission.find(params[:id])
    @submission.destroy

    respond_to do |format|
      format.html { redirect_to submissions_url }
      format.json { head :no_content }
    end
  end
end
