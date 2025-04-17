import { instance } from "./Axios";

interface LoginParams {
  phone: string,
  code: string
}


interface CreatePostParams {
  rightCount: number,
  answeredCount: number,
  timeUsed: number
}

//获取验证码
export function sendCode(phone: string) {
  return instance.get('/word/user/code', { params: { phone: phone } });
}

//登录
export function login(phone: string, code: string) {
  return instance.post('/word/user/login', { phone: phone, code: code } as LoginParams);
}

// 发送打卡请求
export function createPost(post: CreatePostParams) {
  return instance.post('/word/post/create', post)
}