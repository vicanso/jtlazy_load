"use strict"
define 'jtLazyLoad', ['jquery', 'underscore'], (require, exports) ->
  load = (lazyLoadItems, scrollObj) ->
    $ = require 'jquery'
    _ = require 'underscore'
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


  # 初始化定义了指令的 directive-lazyload的元素
  load $ '.directive-lazyload'

  exports.load = load
  return