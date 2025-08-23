import avatarImg from './src/assets/avatar.jpg'
import type { PostModel } from './src/interfaces/post-model'

// index

export const site = 'https://blog.toolplus.vip'

export const title = '鲸鱼在游泳'

export const description = '这是“鲸鱼在游泳”的个人博客，记录技术提升和人生随想'

export const avatar = avatarImg

export const quote =
  '听音乐，品人生'

export const tooltip = {
  content: '检测到页面内容有更新更新，是否刷新页面',
  confirm: '是',
  cancel: '否',
}

export const links = [
  { url: '/', title: '🌐首页' },
  { url: '/tags', title: '🔖标签' },
  { url: '/archive', title: '🗂️归档' },
  { url: '/search', title: '🔍搜索' },
]

export const linkAttr = 'abbrlink'

export const getPostLink = (post: PostModel) => `/posts/${post.data[linkAttr]}`
