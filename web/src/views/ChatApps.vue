<template>
  <div>
    <div class="page-apps custom-scroll">
      <div class="title">
        AI 助手应用中心
      </div>
      <div class="inner" :style="{height: listBoxHeight + 'px'}">
        <ItemList :items="list" v-if="list.length > 0" :gap="20" :width="250">
          <template #default="scope">
            <div class="app-item" :style="{width: scope.width+'px'}">
              <el-image :src="scope.item.icon" fit="cover" :style="{height: scope.width+'px'}"/>
              <div class="title">
                <span class="name">{{ scope.item.name }}</span>
                <div class="opt">
                  <div v-if="hasRole(scope.item.key)">
                    <el-button size="small" type="success" @click="useRole(scope.item.id)">使用</el-button>
                    <el-button size="small" type="danger" @click="updateRole(scope.item,'remove')">移除</el-button>
                  </div>
                  <el-button v-else size="small"
                             style="--el-color-primary:#009999"
                             @click="updateRole(scope.item, 'add')">
                    <el-icon>
                      <Plus/>
                    </el-icon>
                    <span>添加应用</span>
                  </el-button>
                </div>
              </div>
              <div class="hello-msg" ref="elements">{{ scope.item.intro }}</div>
            </div>
          </template>
        </ItemList>
      </div>


    </div>
    <login-dialog :show="showLoginDialog" @hide="getRoles" @success=""/>
  </div>
</template>

<script setup>
import {onMounted, ref} from "vue"
import {ElMessage} from "element-plus";
import {httpGet, httpPost} from "@/utils/http";
import ItemList from "@/components/ItemList.vue";
import {Plus} from "@element-plus/icons-vue";
import LoginDialog from "@/components/LoginDialog.vue";
import {checkSession} from "@/action/session";
import {arrayContains, removeArrayItem, substr} from "@/utils/libs";
import {useRouter} from "vue-router";

const listBoxHeight = window.innerHeight - 97
const list = ref([])
const showLoginDialog = ref(false)
const roles = ref([])
const elements = ref(null)
onMounted(() => {
  httpGet("/api/role/list?all=true").then((res) => {
    const items = res.data
    // 处理 hello message
    for (let i = 0; i < items.length; i++) {
      items[i].intro = substr(items[i].hello_msg, 80)
    }
    list.value = items
  }).catch(e => {
    ElMessage.error("获取应用失败：" + e.message)
  })

  getRoles()
})

const getRoles = () => {
  showLoginDialog.value = false
  checkSession().then(user => {
    roles.value = user.chat_roles
  }).catch(() => {
  })
}

const updateRole = (row, opt) => {
  checkSession().then(() => {
    const title = ref("")
    if (opt === "add") {
      title.value = "添加应用"
      const exists = arrayContains(roles.value, row.key)
      if (exists) {
        return
      }
      roles.value.push(row.key)
    } else {
      title.value = "移除应用"
      const exists = arrayContains(roles.value, row.key)
      if (!exists) {
        return
      }
      roles.value = removeArrayItem(roles.value, row.key)
    }
    httpPost("/api/role/update", {keys: roles.value}).then(() => {
      ElMessage.success({message: title.value + "成功！", duration: 1000})
    }).catch(e => {
      ElMessage.error(title.value + "失败：" + e.message)
    })
  }).catch(() => {
    showLoginDialog.value = true
  })
}

const hasRole = (roleKey) => {
  return arrayContains(roles.value, roleKey, (v1, v2) => v1 === v2)
}

const router = useRouter()
const useRole = (roleId) => {
  router.push({name: "chat", params: {role_id: roleId}})
}
</script>

<style lang="stylus">
@import "@/assets/css/chat-app.styl"
@import "@/assets/css/custom-scroll.styl"
</style>
