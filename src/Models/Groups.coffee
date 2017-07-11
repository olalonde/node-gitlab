BaseModel = require '../BaseModel'

nop = ->

class Groups extends BaseModel
  init: =>
    @access_levels =
      GUEST:      10
      REPORTER:   20
      DEVELOPER:  30
      MASTER:     40
      OWNER:      50

  all: (params = {}, fn = nop) =>
    if 'function' is typeof params
      fn = params
      params = {}
    @debug "Groups::all()"

    params.page ?= 1
    params.per_page ?= 100

    data = []
    cb = (err, retData) =>
      if err
        return fn(err, retData || data)
      else if retData.length == params.per_page
        @debug "Recurse Groups::all()"
        data = data.concat(retData)
        params.page++
        return @get "groups", params, cb
      else
        data = data.concat(retData)
        return fn

    @get "groups", params, cb

  show: (groupId, fn = nop) =>
    @debug "Groups::show()"
    @get "groups/#{parseInt groupId}", fn

  listProjects: (groupId, fn = nop) =>
    @debug "Groups::listProjects()"
    @get "groups/#{parseInt groupId}", fn

  listMembers: (groupId, fn = nop) =>
    @debug "Groups::listMembers()"
    @get "groups/#{parseInt groupId}/members", fn

  addMember: (groupId, userId, accessLevel, fn=null) =>
    @debug "addMember(#{groupId}, #{userId}, #{accessLevel})"

    checkAccessLevel = =>
      for k, access_level of @access_levels
        return true if accessLevel == access_level
      false

    unless do checkAccessLevel
      throw "`accessLevel` must be one of #{JSON.stringify @access_levels}"

    params =
      user_id: userId
      access_level: accessLevel

    @post "groups/#{parseInt groupId}/members", params, fn

  editMember: (groupId, userId, accessLevel, fn = nop) =>
    @debug "Groups::editMember(#{groupId}, #{userId}, #{accessLevel})"

    checkAccessLevel = =>
      for k, access_level of @access_levels
        return true if accessLevel == access_level
      false

    unless do checkAccessLevel
      throw "`accessLevel` must be one of #{JSON.stringify @access_levels}"

    params =
      access_level: accessLevel

    @put "groups/#{parseInt groupId}/members/#{parseInt userId}", params, fn

  removeMember: (groupId, userId, fn = nop) =>
    @debug "Groups::removeMember(#{groupId}, #{userId})"
    @delete "groups/#{parseInt groupId}/members/#{parseInt userId}", fn

  create: (params = {}, fn = nop) =>
    @debug "Groups::create()"
    @post "groups", params, fn

  addProject: (groupId, projectId, fn = nop) =>
    @debug "Groups::addProject(#{groupId}, #{projectId})"
    @post "groups/#{parseInt groupId}/projects/#{parseInt projectId}", null, fn

  deleteGroup: (groupId, fn = nop) =>
    @debug "Groups::delete(#{groupId})"
    @delete "groups/#{parseInt groupId}", fn

  search: (nameOrPath, fn = nop) =>
    @debug "Groups::search(#{nameOrPath})"
    params =
      search: nameOrPath
    @get "groups", params, fn

module.exports = (client) -> new Groups client
