"use strict"
moduleName = 'jtlazy_load'
module = GLOBAL_MODULES[moduleName] = 
  id : moduleName
exports = module.exports = {}

require 'jquery'
require 'underscore'
_ = window._
$ = window.jQuery

exports.load = (lazyLoadItems, scrollObj) ->
  windowHeight = $(window).height()
  bindingEventObj = scrollObj || $(window)

  # 获取动态加载的图片相关信息列表
  getLazyLoadItemInfos = ->
    tmpScrollTop = scrollObj.scrollTop() if scrollObj
    _.compact _.map lazyLoadItems, (obj) ->
      obj = $ obj
      if obj.find('img.hidden').length
        if tmpScrollTop
          top = obj.position().top + tmpScrollTop
        else
          top = obj.offset().top
        {
          top : top
          obj : obj
        }
      else
        null
  
  # 保存图片的相关信息[{top : Integer, obj : jQuery}]
  lazyLoadItemInfos = getLazyLoadItemInfos()



  # 加载图片的函数，由scroll触发
  loadImage = _.debounce ->
    containerObj = scrollObj || $ document
    top = containerObj.scrollTop() - 300
    maxTop = top + windowHeight + 600
    lazyLoadItemInfos = _.filter lazyLoadItemInfos, (lazyLoadItemInfo) ->
      lazyLoadItemInfoTop = lazyLoadItemInfo.top
      if lazyLoadItemInfoTop > top && lazyLoadItemInfoTop < maxTop
        lazyLoadItemInfo.obj.find('img').each ->
          obj = $ @
          img = new Image()
          imgSrc = obj.attr 'data-src'
          img.onload = ->
            obj.removeClass 'hidden'
          img.src = imgSrc
          obj.attr 'src', imgSrc
        false
      else
        true
    if !lazyLoadItemInfos.length
      bindingEventObj.off 'scroll', loadImage
  , 300
  bindingEventObj.scroll loadImage