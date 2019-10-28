import joi from "@hapi/joi";

const configSchema = joi
  .object({
    todoListOrder: joi.array().failover([]),
    todoOrder: joi.array().failover([])
  })
  .failover({ todoListOrder: [], todoOrder: [] })
  .options({ stripUnknown: true, presence: "required" });

export default configSchema;
