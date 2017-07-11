BaseModel = require '../BaseModel'
Utils = require '../Utils'

nop = ->

class Projects extends BaseModel
  init: =>
    @members = @load 'ProjectMembers'
    @hooks =   @load 'ProjectHooks'
    @issues =  @load 'ProjectIssues'
    @labels =  @load 'ProjectLabels'
    @repository = @load 'ProjectRepository'
    @milestones = @load 'ProjectMilestones'
    @deploy_keys = @load 'ProjectDeployKeys'
    @merge_requests = @load 'ProjectMergeRequests'
    @services = @load 'ProjectServices'
    @builds = @load 'ProjectBuilds'
    @pipelines = @load 'Pipelines'
    @runners = @load 'Runners'

  all: (params={}, fn=nop) =>
    if 'function' is typeof params
      fn = params
      params={}
    @debug "Projects::all()"

    params.page ?= 1
    params.per_page ?= 100

    data = []
    cb = (err, retData) =>
      if err
        return fn(err, retData)
      else if retData.length == params.per_page
        @debug "Recurse Projects::all()"
        data = data.concat(retData)
        params.page++
        return @get "projects", params, cb
      else
        data = data.concat(retData)
        return fn null, data

    @get "projects", params, cb

  allAdmin: (params={}, fn=nop) =>
    if 'function' is typeof params
      fn = params
      params={}
    @debug "Projects::allAdmin()"

    params.page ?= 1
    params.per_page ?= 100

    data = []
    cb = (err, retData) =>
      if err
        return fn(retData || data)
      else if retData.length == params.per_page
        @debug "Recurse Projects::allAdmin()"
        data = data.concat(retData)
        params.page++
        return @get "projects/all", params, cb
      else
        data = data.concat(retData)
        return fn

    @get "projects/all", params, cb

  show: (projectId, fn=nop) =>
    @debug "Projects::show()"
    @get "projects/#{Utils.parseProjectId projectId}", fn

  create: (params={}, fn=nop) =>
    @debug "Projects::create()"
    @post "projects", params, fn

  create_for_user: (params={}, fn=nop) =>
    @debug "Projects::create_for_user()"
    @post "projects/user/#{params.user_id}", params, fn

  edit: (projectId, params={}, fn=nop) =>
    @debug "Projects::edit()"
    @put "projects/#{Utils.parseProjectId projectId}", params, fn

  addMember: (params={}, fn=nop) =>
    @debug "Projects::addMember()"
    @post "projects/#{params.id}/members", params, fn

  editMember: (params={}, fn=nop) =>
    @debug "Projects::editMember()"
    @put "projects/#{params.id}/members/#{params.user_id}", params, fn

  listMembers: (params={}, fn=nop) =>
    @debug "Projects::listMembers()"
    @get "projects/#{params.id}/members", fn

  listCommits: (params={}, fn=nop) =>
    @debug "Projects::listCommits()"
    @get "projects/#{params.id}/repository/commits", params, fn

  listTags: (params={}, fn=nop) =>
    @debug "Projects::listTags()"
    @get "projects/#{params.id}/repository/tags", fn

  remove: (projectId, fn = null) =>
    @debug "Projects::remove()"
    @delete "projects/#{Utils.parseProjectId projectId}", fn

  fork: (params={}, fn=nop) =>
    @debug "Projects::fork()"
    @post "projects/fork/#{params.id}", params, fn

  share: (params={}, fn=nop) =>
    @debug "Projects::share()"
    @post "projects/#{Utils.parseProjectId params.projectId}/share", params, fn

  search: (projectName, params={}, fn=nop) =>
    if 'function' is typeof params
      fn = params
      params={}

    @debug "Projects::search()"
    @get "projects/search/#{projectName}", params, fn

  listTriggers: (projectId, fn = null) =>
    @debug "Projects::listTriggers()"
    @get "projects/#{Utils.parseProjectId projectId}/triggers", fn

  showTrigger: (projectId, token, fn = null) =>
    @debug "Projects::showTrigger()"
    @get "projects/#{Utils.parseProjectId projectId}/triggers/#{token}", fn

  createTrigger: (params={}, fn=nop) =>
    @debug "Projects::createTrigger()"
    @post "projects/#{Utils.parseProjectId params.projectId}/triggers", params, fn

  removeTrigger: (projectId, token, fn = null) =>
    @debug "Projects::removeTrigger()"
    @delete "projects/#{Utils.parseProjectId projectId}/triggers/#{token}", fn

module.exports = (client) -> new Projects client
